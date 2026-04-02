//Initialize global variables
tolerance = -1;
size = -1;
label_array = newArray("Mean", "Median", "Min", "Max");

//Direction variables
//FFT_substack_nSlices = 3; //Thickness in slices of substack to generate FFT (ensures neurites on different slices are included);
//n_stdev = 2; //Number of standard deviations above the mean to threshold the FFT
tolerance_range = 0.1; //+/- factor range to test tolerance
tolerance_step = tolerance_range; //Step size to test tolerance
min_size_cutoff = 4; //Smallest size to be exluded in particle analyzer
max_size_cutoff = 20; //Largest size to be exluded in particle analyzer
FFT_min_radius = 1/32; //Ratio of total width of FFT to set as min cutoff - i.e. lowest sptatial frequency
FFT_max_radius = 1/4; //Ratio of total width of FFT to set as max cutoff - i.e. highest sptatial frequency
sector_width = 10; //Width of sector off FFT to look for directionality
n_degrees = 360; //Number of degrees to sample in FFT

close("\\Others");
im = getTitle(); //Get name of active image
setBatchMode(true);


newImage("Statistics", "32-bit black", n_degrees, (2*label_array.length)+1, 1);




	//Get FFT of mask
	selectImage(im); //Be explicit about the image you intend to process
	run("FFT Options...", "raw reuse do");
	selectImage("PS of " + im);
	rename("FFT1");
	//run("Log");
	//run("Gaussian Blur...", "sigma=8");

	//make angle map for drawing sectors on the FFT
	selectWindow("FFT1");
	getDimensions(FFT_width, dummy, dummy, dummy, dummy);
	newImage("Angle", "8-bit black", FFT_width, FFT_width, 1);
	selectWindow("Angle");
	setPixel(FFT_width/2, FFT_width/2, 255);
	run("Invert");
	run("Exact Euclidean Distance Transform (3D)");
	selectWindow("EDT");
	run("Canny Edge", "xsize=1 ysize=1 zsize=1 x-sigma,=1 y-sigma,=1 z-sigma,=1 low=0.2000000 high=0.6000000 angle scaling=-1");
	
	//Create mask for fixed annualr ROI to find direction preference
		selectWindow("EDT");
		setThreshold(FFT_width*FFT_min_radius, FFT_width*FFT_max_radius);
		run("NaN Background");
		imageCalculator("Divide", "EDT","EDT");
		
	//Set angle map to be scaled in degrees and apply distance ROI. It is at 255 right now so scaling so its for 360
		selectWindow("canny phi");
		run("Rotate 90 Degrees Left");
		run("Multiply...", "value=1.41176470588"); //360/255
		imageCalculator("Multiply", "canny phi","EDT");
		close("EDT");
		close("Angle");
		
		
		//Measure statistics for each sector of the FFT
	selectWindow("FFT1");
	run("Select None");
	for(b=0; b<4; b++){
		for(a=45; a<135; a++){
			angle = (a+b*90)%360;
			selectWindow("canny phi");
			run("Select None");
			//Measure for 45 to 135 - then tranform angle map 90° and repeat 4x
			setThreshold(a-sector_width/2, a+sector_width/2);
			run("Create Selection");
			selectWindow("FFT1");
			run("Restore Selection");
			List.setMeasurements();
			run("Select None");
			selectWindow("Statistics");
			for(c=0; c<label_array.length; c++){
				setPixel(angle, c, parseFloat(List.get(label_array[c])));
			}
		}
		selectWindow("canny phi");	
		run("Rotate 90 Degrees Left");
	}
	
	//Output results to results table
	newImage("Polar plots", "RGB black", 1024, 1024, label_array.length);
	setForegroundColor(255, 0, 255);
	makeRectangle(511, 0, 1, 1024);
	run("Fill", "stack");
	makeRectangle(0, 511, 1024, 1);
	run("Fill", "stack");
	run("Select None");
	selectWindow("Statistics");
	results_array = newArray(n_degrees);
	line_array = newArray(4);
	for(a=0; a<label_array.length; a++){
		//Measure FFT aspect ratios
		selectWindow("Statistics");
		makeRectangle(0, a, n_degrees, 1);
		getStatistics(dummy, dummy, min, max);
		
		
	//Create polar plot of FFT aspect ratios
		scale_radius = 512/max;
		selectWindow("Statistics");
		line_array[0] = getPixel((n_degrees-1),a);
		line_array[1] = getPixel((n_degrees-1),a);
		line_array[0] = cos((n_degrees-1-90)*PI/180)*line_array[0]*scale_radius+511;
		line_array[1] = 511-sin((n_degrees-1-90)*PI/180)*line_array[1]*scale_radius; //positive Y is pointing down
		setForegroundColor(0, 255, 0);
		selectWindow("Polar plots");
		Stack.setSlice(a+1);
		setMetadata("Label", label_array[a]);
		max_ratio = -1;
		max_angle = -1;
		for(b=0; b<n_degrees; b++){
			selectWindow("Statistics");
			ratio = getPixel(b, a)/getPixel((b+90)%n_degrees, a); //Measure ratio of orthogonal vectors
			if(ratio > max_ratio){
				max_ratio = ratio;
				max_angle = (b+90)%n_degrees;
			}
			line_array[2] = getPixel(b,a);
			line_array[3] = getPixel(b,a);
			line_array[2] = cos((b-90)*PI/180)*line_array[2]*scale_radius+511;
			line_array[3] = 511-sin((b-90)*PI/180)*line_array[3]*scale_radius;
			selectWindow("Polar plots");
			makeLine(line_array[0], line_array[1], line_array[2], line_array[3]);
			run("Draw", "slice"); 
			line_array[0] = line_array[2];
			line_array[1] = line_array[3]; 			
		}

		//Save results to output matrix
		selectWindow("Statistics");
		setPixel(0, label_array.length + a, max_ratio);
		setPixel(1, label_array.length + a, max_angle);

		//Get polar plot statistics
		selectWindow("Polar plots");
		run("Duplicate...", "title=plot");
		selectWindow("plot");
		run("Split Channels");
		close("plot (red)");
		close("plot (blue)");
		selectWindow("plot (green)");
		run("Invert"); //Mac specific issue
		run("Fill Holes");
		run("Create Selection");

		List.setMeasurements;
		ellipse_ratio = parseFloat(List.get("Minor"))/parseFloat(List.get("Major"));
		if(isOpen("Results")){ //Close the results table if it is open
			selectWindow("Results");
			run("Close");
		}

		setResult(label_array[a] + " - Ratio", 0, ellipse_ratio); //Degree of directionality
		setResult(label_array[a] + " - Angle", 0, parseFloat(List.get("Angle"))); //Angle of direction bias
		selectWindow(im);
		List.setMeasurements;
		neurite_area = parseFloat(List.get("RawIntDen"))/255;
		setResult(label_array[a] + " - Neurite Area (px)", 0, neurite_area); //Sanity check to make sure a region of neurites was selected
		close("plot (green)");		
	}
	//close("Polar plots");
	close("FFT1");
	selectWindow("Statistics");
	run("Select None");
	selectWindow("canny phi");
	run("Select None");
	
	

	
setBatchMode("exit and display");