#Müller Glia FFT Analysis Macros

This repository contains ImageJ/Fiji macros used to quantify the directional organization of RLBP1-labeled Müller glial stalks in retinal sections.

The workflow has two main steps:

Skeletonization / centerline extraction of labeled Müller glial stalks
FFT-based analysis of directional organization from the resulting mask

These macros were developed for retinal section images in which Müller glia are labeled with RLBP1, but the general workflow may also be useful for other images containing aligned filamentous structures.

##Files
Skeletonization macro.ijm
Converts an image of labeled stalks into a simplified centerline mask by identifying local intensity maxima across image columns and rows.
CalculateFFT_Macro.ijm
Performs FFT-based directional analysis on the centerline mask, generates polar plots, and outputs measurements related to isotropy and orientation.

##Overview of the workflow

###Step 1: Skeletonization / centerline extraction

The skeletonization macro reduces thick labeled structures into a simpler mask that preserves their overall spatial arrangement.

How it works:

The macro scans the image column by column
It identifies local maxima using Find Maxima
It repeats the same process row by row
The horizontal and vertical masks are combined
The output is a simplified centerline mask of the labeled structures

This step helps reduce variation caused by signal thickness while preserving the organization of the Müller glial stalks.

###Step 2: FFT-based directional analysis

The FFT macro analyzes the centerline mask in frequency space to quantify directional organization.

How it works:

The image is transformed using FFT
The FFT image is converted into an angular representation
Signal is sampled across 360 degrees
A polar plot is generated from the angular measurements
An ellipse is fit to the polar plot
The ellipse aspect ratio is used as a readout of isotropy

Interpretation:

Lower aspect ratio values indicate a more elongated polar plot and stronger directional coherence
Higher aspect ratio values indicate a more circular polar plot and a more isotropic, less directionally organized pattern

The macro also reports the dominant angle, which reflects the orientation bias of the structure.

###Requirements

These macros were written for ImageJ/Fiji.

Plugins/functions used include:

FFT tools built into Fiji
Find Maxima
Canny Edge
Exact Euclidean Distance Transform (3D)

Please make sure these plugins are installed and available in your Fiji distribution before running the macros.

###Recommended input

These macros are intended for:

retinal section images 
z-stacks that have been collected from RLBP1-labeled Müller glia
images that are converted to maximum-intensity projections before FFT analysis

For the analysis described in the manuscript:

.nd2 images were processed in Fiji
centerline masks were generated from projected images
a standardized ROI was then analyzed by FFT

###How to use
1. Generate the centerline mask

Open your projected image in Fiji and run:

Skeletonization macro.ijm

This will produce a skeleton-like centerline mask based on local intensity maxima.

2. Run FFT analysis

With the centerline mask active, run:

CalculateFFT_Macro.ijm

This macro will:

calculate the FFT
generate polar plots
measure ellipse aspect ratio
report orientation angle
output values in the Results table
Output

The FFT macro generates:

a polar plot for the analyzed image
a Results table containing:
ellipse ratio
angle of directional bias
neurite/structure area as a sanity check

In this workflow, the ellipse ratio is interpreted as an index of isotropy:

closer to 0 = more directional / more aligned
closer to 1 = more isotropic / less aligned
Adjustable parameters
In Skeletonization macro.ijm
skeleton_prominence
Controls the prominence threshold used by Find Maxima
In CalculateFFT_Macro.ijm

Key parameters include:

FFT_min_radius
FFT_max_radius
sector_width
n_degrees

These parameters control how the FFT signal is sampled and how directional bias is measured.

If you adapt this workflow for a different image type, these values may need to be adjusted.

Notes
These macros are designed to quantify directional organization, not full cell morphology
The output depends on the labeled signal used as input
In the associated manuscript, this workflow is applied to RLBP1-labeled Müller glial stalks and interpreted as a readout of marker-defined structural organization
