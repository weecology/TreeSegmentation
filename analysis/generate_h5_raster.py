import Hyperspectral
import argparse
import sys
import rasterio

def run(h5_path,rgb_filename,save_dir,bands="false_color"):
    #Crop and create raster
    status = Hyperspectral.generate_raster(h5_path = h5_path, rgb_filename=rgb_filename, bands=bands, save_dir=save_dir)
    print("{} : {}".format(rgb_filename,status))

    

    