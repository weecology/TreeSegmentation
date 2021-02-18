import Hyperspectral
import argparse
import sys
import rasterio
import glob

def parse_args():
    parser = argparse.ArgumentParser(
        description='Simple script for cutting hyperspectral band data')
    parser.add_argument("--rgb_filename")
    parser.add_argument("--siteID",default="MLBS")  
    parser.add_argument("--year",default="2018")     
    parser.add_argument("--false_color", action="store_true")
    parser.add_argument("--save_dir",default=".")
    
    return(parser.parse_args())
    
def run(h5_path,rgb_filename,save_dir,false_color=False):
    #Crop and create raster
    try:
        status = Hyperspectral.generate_raster(h5_path = h5_path, rgb_filename=rgb_filename, false_color=false_color, save_dir=save_dir)
        print("{} : {}".format(rgb_filename,status))
    except Exception as e:
        print("{} : {}".format(rgb_filename,e))
