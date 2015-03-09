function machine = apply_multipole_errors(name, machine, errors, multi)

families = fieldnames(errors);

nr_mach = size(errors.(families{1}).Bn_norm, 1);

save([name,'_apply_multipole_errors_input.mat'], 'errors', 'multi');

if ~iscell(machine{1})
    machine = repmat({machine},nr_mach,1);
end

if length(machine) ~= nr_mach
    warning('MATLAB:DifferentSizes',...
        'Incompatibility between errors and machine lengths.\n Using minimum of both.');
    nr_mach = min([length(machine),nr_mach]);
end

for i=1:nr_mach
    for ii =1:length(families);
        errors_fam = errors.(families{ii});
        config_fam = multi.(families{ii});
        
        rms_monomials = config_fam.order;
        r0 = config_fam.r0;
        main_monomial = config_fam.main_multipole;
        idx = errors.(families{ii}).indcs;
        
        Bn_norm = zeros(max(rms_monomials),length(idx));
        An_norm = Bn_norm;
        Bn_norm(rms_monomials,:) = squeeze(errors_fam.Bn_norm(i,:,:));
        An_norm(rms_monomials,:) = squeeze(errors_fam.An_norm(i,:,:));
        
        machine{i}  = lnls_set_multipoles(machine{i}, Bn_norm, An_norm, main_monomial, r0, idx);
    end
end




