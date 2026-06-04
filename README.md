# mep-extraction-eeglab-brainvision
EEGLAB-based MATLAB pipeline for extracting Motor Evoked Potentials (MEPs) from BrainVision EMG recordings, including feature extraction and manual quality control.

## Overview
This repository contains a MATLAB script for extracting Motor Evoked Potentials (MEPs) from preprocessed EMG data recorded using a BrainVision system and processed in EEGLAB.
The script reflects the original laboratory pipeline and is intended to preserve full transparency and reproducibility of the feature extraction process.

---
## Author
Naomi Bevacqua
naomi.bevacqua@ugent.be
Date: 11/02/2026

---

## Description
The script performs automated extraction of MEP-related features from epoched EEG data. Specifically, it computes:
- Peak-to-peak amplitude of MEP responses (FDI and ADM channels)
- Pre-stimulus EMG activity (rectified mean)
- Peak latency proxy (based on peak separation within the analysis window)
In addition, a manual quality control step is included to visually inspect each epoch and classify trials.

---
## Processing Pipeline
1. EEG data validation (EEGLAB format)
2. Band-pass filtering (high-pass at 1 Hz)
3. Resampling to 1000 Hz
4. Epoching relative to stimulus onset
5. Feature extraction within defined time windows:
   - Post-stimulus window: 15–60 ms
   - Pre-stimulus window: 10–110 ms
6. Manual visual inspection and trial labeling
7. Export of results to spreadsheet format

---

## Channel Definition
The script assumes a fixed channel assignment:
- Channel 1 → FDI (First Dorsal Interosseous)
- Channel 2 → ADM (Abductor Digiti Minimi)

⚠️ Channel order must be verified before running the script, as it depends on dataset-specific montage configuration.

---

## Output
The output file (.xlsx format) contains a matrix with 7 columns:
1. FDI peak-to-peak amplitude
2. ADM peak-to-peak amplitude
3. FDI pre-stimulus rectified mean EMG activity
4. ADM pre-stimulus rectified mean EMG activity
5. FDI peak latency proxy
6. ADM peak latency proxy
7. Trial quality label (1 = good, 0 = bad, unassigned = 0)

---

## Manual Quality Control
Each epoch is displayed for visual inspection. The user assigns a label:
- `1` = valid (good trial)
- `0` = rejected (bad trial)
- `9` = stop processing

⚠️ Trials are not automatically rejected by the algorithm.

---

## Requirements
- MATLAB (tested on R2021a or later)
- EEGLAB toolbox
---

## Usage

1. Open EEGLAB in MATLAB:
> eeglab
2. Import your EEG/EMG recording into EEGLAB.
3. Ensure the dataset is loaded in the MATLAB workspace as EEG.
4. Assign a meaningful dataset name in EEGLAB (this name will be used to generate the output filename).
5. Run the script from the MATLAB Command Window:
> run('MEPextraction.m');

---

## Notes
This script performs feature extraction only and does not implement automatic artifact rejection.
All preprocessing steps follow EEGLAB standard functions.
The workflow is intentionally kept close to the original laboratory implementation for reproducibility.

---

License

This project is licensed under the MIT License. See the LICENSE file for details.

---

Citation

If you use this script, please cite this repository:

Bevacqua, N. (2026). MEP Extraction (EEGLAB Pipeline). GitHub repository.  
https://github.com/bevacquanaomi/mep-extraction-eeglab-brainvision
