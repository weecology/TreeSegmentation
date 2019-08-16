import Hyperspectral
import argparse
import sys
import rasterio

def run(h5_path,rgb_filename,save_dir,false_color=True):
    #Crop and create raster
    try:
        status=Hyperspectral.generate_raster(h5_path = h5_path, rgb_filename=rgb_filename, false_color=false_color, save_dir=save_dir)
        print("{} : {}".format(rgb_filename,status))
    except Exception as e:
        print("{} : {}".format(rgb_filename,e))
        
#run(h5_path="/Users/ben/Downloads/2018_2/FullSite/D07/2018_MLBS_3/L3/Spectrometer/Reflectance/NEON_D07_MLBS_DP3_541000_4140000_reflectance.h5",
    #rgb_filename="/Users/Ben/Documents/NeonTreeEvaluation/MLBS/training/2018_MLBS_3_541000_4140000_image_crop2.tif",
    #save_dir="/Users/Ben/Documents/NeonTreeEvaluation/MLBS/training/",false_color=True)

    