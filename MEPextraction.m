%% MEP Extraction Script
% Author: Naomi Bevacqua
% Date: 11/02/2026
%
% Description:
% Extraction of Motor Evoked Potentials (MEPs) from EEGLAB-processed EMG/EEG data.
%
% NOTE:
% - This script performs FEATURE EXTRACTION only.
% - Trial quality classification is performed manually.

%% =========================
%  Load / preprocess EEG
%  =========================

% Ensure EEGLAB dataset is already loaded in workspace
output_filename = 'MEP_results.xlsx';
EEG = eeg_checkset(EEG);

% Bandpass filtering
EEG = pop_eegfiltnew(EEG, 'locutoff', 1, 'plotfreqz', 1);

% Store dataset
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'gui', 'off');

% Resample
EEG = pop_resample(EEG, 1000);
EEG = eeg_checkset(EEG);

% Epoching
EEG = pop_epoch(EEG, {'S  1'}, [-0.11 0.06], 'epochinfo', 'yes');
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'gui', 'off');

eeglab redraw;

% Visual inspection (optional)
pop_eegplot(EEG, 1, 1, 1);

%% =========================
%  PARAMETERS
%  =========================

channel_fdi = 1;
channel_adm = 2;

% Time windows (ms)
windpost = struct('start', 15, 'stop', 60);
emgwindpre = struct('start', 10, 'stop', 110);
timevec = EEG.times;
idx_post = find(timevec >= windpost.start & timevec <= windpost.stop);
idx_pre  = find(timevec >= -emgwindpre.stop & timevec <= -emgwindpre.start);
nEpochs = EEG.trials;

%% =========================
%  OUTPUT VARIABLES
%  =========================

outmat = zeros(nEpochs, 7);
minfdi_all = zeros(nEpochs,1);
maxfdi_all = zeros(nEpochs,1);
minadm_all = zeros(nEpochs,1);
maxadm_all = zeros(nEpochs,1);

%% =========================
%  FEATURE EXTRACTION LOOP
%  =========================

for ep = 1:nEpochs

    signal_fdi = squeeze(EEG.data(channel_fdi, idx_post, ep));
    signal_adm = squeeze(EEG.data(channel_adm, idx_post, ep));
    t_post = timevec(idx_post);

    % Peak detection (simple max/min approach)
    [minfdi, minfdi_idx] = min(signal_fdi);
    [maxfdi, maxfdi_idx] = max(signal_fdi);

    [minadm, minadm_idx] = min(signal_adm);
    [maxadm, maxadm_idx] = max(signal_adm);

    % Peak-to-peak amplitudes
    ptpfdi = maxfdi - minfdi;
    ptpadm = maxadm - minadm;
    outmat(ep,1) = ptpfdi;
    outmat(ep,2) = ptpadm;

    % Pre-stim EMG activity
    signal_prefdi = squeeze(EEG.data(channel_fdi, idx_pre, ep));
    signal_preadm = squeeze(EEG.data(channel_adm, idx_pre, ep));
    outmat(ep,3) = mean(abs(signal_prefdi));
    outmat(ep,4) = mean(abs(signal_preadm));

    % Latency proxy (peak separation)
    outmat(ep,5) = abs(t_post(maxfdi_idx) - t_post(minfdi_idx));
    outmat(ep,6) = abs(t_post(maxadm_idx) - t_post(minadm_idx));

    % Store indices for plotting
    minfdi_all(ep) = idx_post(minfdi_idx);
    maxfdi_all(ep) = idx_post(maxfdi_idx);
    minadm_all(ep) = idx_post(minadm_idx);
    maxadm_all(ep) = idx_post(maxadm_idx);

end

%% =========================
%  MANUAL QUALITY CONTROL
%  =========================

start_epoch = input('Start epoch (default = 1): ');

if isempty(start_epoch)
    start_epoch = 1;
end

% Manual QC note
% 1 = good trial
% 0 = bad trial (reject)
% 9 = stop

figure;

for ep = start_epoch:nEpochs

    clf;

    sig_f_full = squeeze(EEG.data(channel_fdi,:,ep));
    sig_a_full = squeeze(EEG.data(channel_adm,:,ep));

    plot(timevec, sig_f_full, 'b'); hold on;
    plot(timevec, sig_a_full, 'r');

    % Mark peaks
    plot(timevec(minfdi_all(ep)), EEG.data(channel_fdi,minfdi_all(ep),ep), 'bo','LineWidth',2);
    plot(timevec(maxfdi_all(ep)), EEG.data(channel_fdi,maxfdi_all(ep),ep), 'bs','LineWidth',2);

    plot(timevec(minadm_all(ep)), EEG.data(channel_adm,minadm_all(ep),ep), 'ro','LineWidth',2);
    plot(timevec(maxadm_all(ep)), EEG.data(channel_adm,maxadm_all(ep),ep), 'rs','LineWidth',2);

    xline(0,'k--');

    title(sprintf('Epoch %d | 1=GOOD 0=BAD 9=STOP', ep));
    legend('FDI','ADM');
    grid on;

    drawnow;

    valid = input('1 = good | 0 = bad | 9 = stop : ');

    if isempty(valid)
        continue;
    end

    if valid == 9
        disp('Manual stop.');
        break;
    end

    if valid == 0 || valid == 1
        outmat(ep,7) = valid;
    end

end

%% =========================
%  SAVE OUTPUT
%  =========================

if isfield(EEG, 'setname') && ~isempty(EEG.setname)
    base_name = EEG.setname;
elseif isfield(EEG, 'filename') && ~isempty(EEG.filename)
    base_name = erase(EEG.filename, '.set');
else
    base_name = 'MEP_results';
end

output_filename = [base_name '_MEP_results.xlsx'];

writematrix(outmat, output_filename);
disp('MEP extraction completed.');