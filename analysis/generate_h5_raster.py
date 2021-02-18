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
    
def run(h5_path,rgb_filename,save_dir,false_color=True):
    #Crop and create raster
    try:
        status = Hyperspectral.generate_raster(h5_path = h5_path, rgb_filename=rgb_filename, false_color=false_color, save_dir=save_dir)
        print("{} : {}".format(rgb_filename,status))
    except Exception as e:
        print("{} : {}".format(rgb_filename,e))
        
if __name__ == "__main__":
    
    #parse args
    args = parse_args()
    
    #get geoindex
    #crop Hyperspectral 3 band
    src = rasterio.open(args.rgb_filename)
    ext = src.bounds
    
    #get geodata
    easting = int(ext.left/1000)*1000
    northing = int(ext.bottom/1000)*1000
    geo_index = "{}_{}".format(easting,northing)
    
    h5_files=glob.glob("/orange/ewhite/NeonData/{}/DP3.30006.001/{}/**/Reflectance/*.h5".format(args.siteID,args.year),recursive=True)    
    h5_path = [x for x in h5_files if geo_index in x][0]
    
    Hyperspectral.generate_raster(h5_path = h5_path, rgb_filename=args.rgb_filename, false_color=args.false_color, save_dir=args.save_dir)
