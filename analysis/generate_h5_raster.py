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
    
#run(h5_path="/orange/ewhite/NeonData/SCBI/DP3.30006.001/2019/FullSite/D02/2019_SCBI_3/L3/Spectrometer/Reflectance/NEON_D02_SCBI_DP3_747000_4309000_reflectance.h5",
    #rgb_filename="/orange/ewhite/b.weinstein/NEON/SCBI/2019/NEONPlots/Camera/L3/SCBI_002.tif",
    #save_dir="/orange/ewhite/b.weinstein/NEON/SCBI/2019/NEONPlots/Hyperspectral/L3/",
    #false_color=False)

    