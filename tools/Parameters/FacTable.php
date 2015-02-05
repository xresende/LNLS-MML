<?php

class FacConnection {
    const server_address = '127.0.0.1';
    const user = 'prm_editor';
    const password = 'prm0';
    const database = 'parameters';

    protected $mysqli;

    function FacConnection()
    {
        $this->mysqli = new mysqli(
            self::server_address,
            self::user,
            self::password,
            self::database
        );
        if ($this->mysqli->connect_errno) {
            echo "Failed to connect to MySQL: " . $this->mysqli->connect_error;
            $this->mysqli = false;
        }
    }
}

class FacTable extends FacConnection {
    function FacTable()
    {
        $this->FacConnection();
    }

    function read_parameter($name)
    {
        if (!$this->mysqli)
            return false;

        $r = $this->read_all_with_name_from_table($name, 'parameter');
        if (!$r)
            return false;
        else {
            $row = $r->fetch_assoc();
            return $this->get_text_fields($row);
        }
    }

    function read_all_with_name_from_table($name, $table)
    {
        $query = "SELECT * FROM " .
            $this->mysqli->real_escape_string($table) .
            " WHERE name='" .
            $this->mysqli->real_escape_string($name) . "';";

        return $this->mysqli->query($query);
    }

    function get_text_fields($cols)
    {
        $fields = array();
        foreach ($cols as $col => $value) {
            $field = $this->convert_col_to_field($col);
            if ($field == 'symbol')
                $fields[$field] = $this->append_math_tags($value);
            elseif ($field == 'is_derived')
                $fields[$field] = $this->convert_integer_to_bool_text($value);
            else
                $fields[$field] = $value;
        }
        return $fields;
    }

    function convert_col_to_field($col)
    {
        if ($col == 'team')
            return 'group';
        else
            return $col;
    }

    function append_math_tags($value)
    {
        return "<math>" . $value . "</math>";
    }

    function convert_integer_to_bool_text($value)
    {
        if ($value)
            return "True";
        else
            return "False";
    }

    function write_parameter($fields)
    {
        if (!$this->mysqli)
            return false;

        $db_fields = $this->get_db_fields($fields);

        $r = $this->read_parameter($db_fields['name']);
        if (!$r)
            $query = $this->build_insert_query($db_fields, 'parameter');
        else
            $query = $this->build_update_parameter_query($db_fields);

        return $this->mysqli->query($query);
    }
    
    function get_db_fields($fields)
    {
        $db_fields = array();
        foreach ($fields as $key => $value) {
            if ($key == 'symbol')
                $db_fields[$key] = $this->strip_math_tags($value);
            elseif ($key == 'is_derived')
                $db_fields[$key] = $this->convert_bool_text_to_integer($value);
            else
                $db_fields[$key] = $this->convert_identity($value);
        }
        return $db_fields;
    }
    
    function build_insert_query($values, $table)
    {
        $query = "INSERT INTO " . $table . " VALUES (" .
            "'" . implode("', '", $values) . "');";
        return $query;
    }

    function build_update_parameter_query($db_fields)
    {
        $query = "UPDATE parameter SET " .
            "team='" . $db_fields['group'] . "', " .
            "symbol='" . $db_fields['symbol'] . "', " .
            "units='" . $db_fields['units'] . "', " .
            "is_derived='" . $db_fields['is_derived'] . "', " .
            "value='" . $db_fields['value'] . "' " .
            "WHERE name='" . $db_fields['name'] . "';";

        return $query;
    }

    function convert_identity($value)
    {
        return $this->mysqli->real_escape_string($value);
    }

    function strip_math_tags($value)
    {
        return $this->mysqli->real_escape_string(strip_tags($value));
    }

    function convert_bool_text_to_integer($value)
    {
        if (strtoupper($value) == 'TRUE')
            return 1;
        else
            return 0;
    }

    function write_dependencies($parameter, array $dependencies)
    {
        if (!$this->mysqli)
            return false;

        $query = "INSERT INTO dependency VALUES ";
        $values = array();
        foreach($dependencies as $dep) {
            $value = "('" . $parameter . "', '" . $dep . "')";
            array_push($values, $value);
        }
        $query .= implode(', ', $values) . ";";

        return $this->mysqli->query($query);
    }

    function write_expression($parameter, $expression)
    {
        if (!$this->mysqli)
            return false;

        $r = $this->read_all_with_name_from_table($parameter, $expression);
        if ($r->num_rows > 0) {
            $query = "UPDATE expression SET expression='" .
                $expression . "' WHERE name='" .
                $parameter . "';";
        } else {
            $query = "INSERT INTO expression VALUES ('" .
                $parameter . "', '" . $expression . "');";
        }

        return $this->mysqli->query($query);
    }

    function rename_parameter($name, $new_name)
    {
        if (!$this->mysqli)
            return false;

        $tables = array('parameter', 'dependency', 'expression');
        $r = true;
        foreach ($tables as $table) {
            $query = "UPDATE " . $table . " SET name='" .
                $new_name . "' WHERE name='" .
                $name . "';";

            $r = true && $this->mysqli->query($query);
        }

        return $r;
    }

    function erase_parameter($parameter)
    {
        return $this->erase('parameter', $parameter);
    }

    function erase_dependencies($parameter)
    {
        return $this->erase('dependency', $parameter);
    }

    function erase_expression($parameter)
    {
        return $this->erase('expression', $parameter);
    }

    function erase($table, $parameter)
    {
        if (!$this->mysqli)
            return false;

        $query = "DELETE FROM " . $table . " WHERE name='" .
            $parameter . "';";

        return $this->mysqli->query($query);
    }
}

class FacEvaluator extends FacConnection {
    const max_depth = 1000;

    static $valid_symbols = array(
        ' ', '.', '(', ')', ',',
        '0', '1', '2', '3', '4',
        '5', '6', '7', '8', '9'
    );
    static $valid_operators = array('+', '-', '*', '/');
    static $valid_functions = array(
        'sqrt', 'pow', 'exp',
        'asin', 'acos', 'atan',
        'sin', 'cos', 'tan'
    );

    public $expression;
    private $parameters;
    private $depth;

    function FacEvaluator($expression)
    {
        $this->FacConnection();

        $this->expression = $expression;
        $this->parameters = array();
        $this->depth = 0;
    }

    function evaluate()
    {
        $expr = $this->replace_parameters($this->expression);
        if (!$this->validate_final_expression($expr))
            throw new Exception('invalid expression');
        else
            return eval($expr);
    }

    function replace_parameters($expression)
    {
        if ($depth++ >= self::max_depth)
            throw new Exception('max depth achieved');

        if (substr_count($expression, '"') % 2)
            throw new Exception('double quotes not matching');

        $parameters = array();
        $split = explode('"', $parameters);
        for ($i = 0; $i < count($split); $i++)
            if ($i % 2)
                array_push($parameters, $split[$i]);

        foreach ($parameters as $p) {
            if (!in_array($p, $this->parameters))
                $this->parameters[$p] = $this->get_value_or_expression($p);

            $parameter = '"' . $p . '"';
            $value = strval($this->parameters[$p]);
            $expression = str_replace($parameter, $value, $expression);
        }

        return $expression;
    }

    function get_value_or_expression($parameter)
    {
        $p = $this->read_parameter($parameter);
        if ($p['is_derived'])
            return '(' . $this->replace_parameters($p['value']) . ')';
        else
            return $p['value'];
    }

    function read_parameter($parameter)
    {
        $query = "SELECT * FROM parameter WHERE name='" .
            $parameter . "';";
        $r = $this->mysqli->query($query);

        $row = $r->fetch_assoc();
        if (!$row)
            throw new Exception('parameter ' . $parameter . ' not found');

        if ($row['is_derived'])
            $value = $this->read_expression($parameter);
        else
            $value = $row['value'];

        return array($row['is_derived'], $value);
    }

    function read_expression($parameter)
    {
        $query = "SELECT * FROM expression WHERE name='" .
            $parameter . "';";
        $r = $this->mysqli->query($query);

        $row = $r->fetch_assoc();
        if (!$row)
            throw new Exception('expression for ' . $parameter . ' not found');
        else
            return $row['expression'];
    }

    function validate_final_expression($expression)
    {
        foreach (self::$valid_symbols as $s)
            $expression = str_replace($s, '', $expression);
        foreach (self::$valid_operators as $o)
            $expression = str_replace($o, '', $expression);
        foreach (self::$valid_functions as $f)
            $expression = str_replace($f, '', $expression);

        if ($expression === '')
            return true;
        else
            return false;
    }
}

class FacDependentTracker extends FacConnection {
    private $parameter;

    function FacDependentTracker($parameter)
    {
        $this->FacConnection();
        $this->parameter = $parameter;
    }

    function get_dependents()
    {
        $query = "SELECT * FROM dependency;";
        $r = $this->mysqli->query($query);
        $table = $r->fetch_all();

        $s = new FacSet();
        $t = new FacSet($this->parameter);
        $n = $s->count();
        while (true) {
            $u = new FacSet();
            foreach ($table as $row)
                foreach($t->elements as $e)
                    if ($row[1] == $e) {
                        $u->put($row[0]);
                        $s->put($row[0]);
                    }

            $new_n = $s->count();
            if ($new_n > $n) {
                $n = $new_n;
                $t = $u;
            } else
                break;            
        }

        return $s->elements;
    }
}

class FacSet {
    public $elements = array();

    function FacSet(array $elements)
    {
        foreach ($elements as $x)
            $this->put($x);
    }

    function put($x)
    {
        if (!in_array($x, $this->elements))
            array_push($this->elements, $x);
    }

    function count()
    {
        return count($this->elements);
    }
}

?>