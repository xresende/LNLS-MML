function dynapt = tracy3_load_fmap_data(fname)

% loads raw data
[~, raw_data] = hdrload(fname);

% finds number of x points (nx) and y points (ny) in 'fmap.out'
nx = find(raw_data(2:end,1) ~= raw_data(1,1), 1);
ny = size(raw_data,1)/nx;

% loads data into 'dynapt' matrix
dynapt = zeros(size(raw_data));
idx = 1;
for j=0:(ny-1)
    m=nx;
    controle=0;
    while ((controle < 1) && (m>=1))
        if (raw_data(j*nx+m,3)==0)
            controle=controle+1;
        end
        m=m-1;
    end
    dynapt(idx,:) = raw_data(j*nx+m+1,:); idx = idx + 1;
end