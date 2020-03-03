import Hyperspectral
import argparse
import sys
import rasterio

def run(h5_path,rgb_filename,save_dir,false_color=True):
    #Crop and create raster
    try:
        status = Hyperspectral.generate_raster(h5_path = h5_path, rgb_filename=rgb_filename, false_color=false_color, save_dir=save_dir)
        print("{} : {}".format(rgb_filename,status))
    except Exception as e:
        print("{} : {}".format(rgb_filename,e))