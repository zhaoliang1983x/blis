function r_val = plot_all_md( is_mt )

if is_mt == 1
	thr_str = 'mt';
else
	thr_str = 'st';
end

if 1
dt_combos = gen_dt_combos();
else
dt_combos( 1, : ) = [ 'ssss' ];
dt_combos( 2, : ) = [ 'sssd' ];
dt_combos( 3, : ) = [ 'ssds' ];
dt_combos( 4, : ) = [ 'sdss' ];
dt_combos( 5, : ) = [ 'dsss' ];
dt_combos( 6, : ) = [ 'ddds' ];
dt_combos( 7, : ) = [ 'dddd' ];
end

n_combos = size(dt_combos,1);

filetemp_blis = '../output_%s_%sgemm_asm_blis.m';
filetemp_open = '../output_%s_%sgemm_openblas.m';

% Construct filenames for the "reference" (single real) data, then load
% the data files, and finally save the results to different variable names.
file_blis_sref = sprintf( filetemp_blis, thr_str, 'ssss' );
file_open_sref = sprintf( filetemp_open, thr_str, 'ssss' );
%str = sprintf( '  Loading %s', file_blis_sref ); disp(str);
run( file_blis_sref )
%str = sprintf( '  Loading %s', file_open_sref ); disp(str);
run( file_open_sref )
data_gemm_asm_blis_sref( :, : ) = data_gemm_asm_blis( :, : );
data_gemm_openblas_sref( :, : ) = data_gemm_openblas( :, : );

% Construct filenames for the "reference" (double real) data, then load
% the data files, and finally save the results to different variable names.
file_blis_dref = sprintf( filetemp_blis, thr_str, 'dddd' );
file_open_dref = sprintf( filetemp_open, thr_str, 'dddd' );
%str = sprintf( '  Loading %s', file_blis_dref ); disp(str);
run( file_blis_dref )
%str = sprintf( '  Loading %s', file_open_dref ); disp(str);
run( file_open_dref )
data_gemm_asm_blis_dref( :, : ) = data_gemm_asm_blis( :, : );
data_gemm_openblas_dref( :, : ) = data_gemm_openblas( :, : );

% Construct filenames for the "reference" (single complex) data, then load
% the data files, and finally save the results to different variable names.
file_blis_cref = sprintf( filetemp_blis, thr_str, 'cccs' );
file_open_cref = sprintf( filetemp_open, thr_str, 'cccs' );
%str = sprintf( '  Loading %s', file_blis_cref ); disp(str);
run( file_blis_cref )
%str = sprintf( '  Loading %s', file_open_cref ); disp(str);
run( file_open_cref )
data_gemm_asm_blis_cref( :, : ) = data_gemm_asm_blis( :, : );
data_gemm_openblas_cref( :, : ) = data_gemm_openblas( :, : );

% Construct filenames for the "reference" (double complex) data, then load
% the data files, and finally save the results to different variable names.
file_blis_zref = sprintf( filetemp_blis, thr_str, 'zzzd' );
file_open_zref = sprintf( filetemp_open, thr_str, 'zzzd' );
%str = sprintf( '  Loading %s', file_blis_zref ); disp(str);
run( file_blis_zref )
%str = sprintf( '  Loading %s', file_open_zref ); disp(str);
run( file_open_zref )
data_gemm_asm_blis_zref( :, : ) = data_gemm_asm_blis( :, : );
data_gemm_openblas_zref( :, : ) = data_gemm_openblas( :, : );

fig = figure;
orient( fig, 'landscape' );
set(gcf,'Position',[0 0 2000 900]);
set(gcf,'PaperUnits', 'inches');
set(gcf,'PaperSize', [64 33]);
set(gcf,'PaperPosition', [0 0 64 33]);
%set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperPositionMode','manual');         
set(gcf,'PaperOrientation','landscape');

for dti = 1:n_combos
%for dti = 1:1

	% Grab the current datatype combination.
	combo = dt_combos( dti, : );

	str = sprintf( 'Plotting %d: %s', dti, combo ); disp(str);

	if combo(4) == 's'
		data_gemm_asm_blis_ref( :, : ) = data_gemm_asm_blis_sref( :, : );
		data_gemm_openblas_ref( :, : ) = data_gemm_openblas_sref( :, : );
	elseif combo(4) == 'd'
		data_gemm_asm_blis_ref( :, : ) = data_gemm_asm_blis_dref( :, : );
		data_gemm_openblas_ref( :, : ) = data_gemm_openblas_dref( :, : );
	end

	if ( combo(1) == 'c' || combo(1) == 'z' ) && ...
	   ( combo(2) == 'c' || combo(2) == 'z' ) && ...
	   ( combo(3) == 'c' || combo(3) == 'z' )
		if combo(4) == 's'
			data_gemm_asm_blis_ref( :, : ) = data_gemm_asm_blis_cref( :, : );
			data_gemm_openblas_ref( :, : ) = data_gemm_openblas_cref( :, : );
		elseif combo(4) == 'd'
			data_gemm_asm_blis_ref( :, : ) = data_gemm_asm_blis_zref( :, : );
			data_gemm_openblas_ref( :, : ) = data_gemm_openblas_zref( :, : );
		end
	end

	% Construct filenames for the data files from templates.
	file_blis = sprintf( filetemp_blis, thr_str, combo );
	file_open = sprintf( filetemp_open, thr_str, combo );

	% Load the data files.
	%str = sprintf( '  Loading %s', file_blis ); disp(str);
	run( file_blis )
	%str = sprintf( '  Loading %s', file_open ); disp(str);
	run( file_open )

	% Plot the result.
	plot_gemm_perf( combo, ...
	                data_gemm_asm_blis, ...
	                data_gemm_asm_blis_ref, ...
	                data_gemm_openblas, ...
	                data_gemm_openblas_ref, ...
	                is_mt, dti );

end


if 0
set(gcf,'Position',[0 0 2000 900]);
set(gcf,'PaperUnits', 'inches');
set(gcf,'PaperSize', [48 22]);
set(gcf,'PaperPosition', [0 0 48 22]);
%set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperPositionMode','manual');         
set(gcf,'PaperOrientation','landscape');
end
print(gcf, 'gemm_md','-bestfit','-dpdf');
%print(gcf, 'gemm_md','-fillpage','-dpdf');