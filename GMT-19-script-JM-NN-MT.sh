#!/bin/sh
# Purpose: Gridding data from the XYZ table by nearest neighbor algorithm, here: Mariana Trench
# GMT modules: gmtset, gmtdefaults, gmtinfo, gmtconvert, nearneighbor, grdcontour, pscoast, pstext, gmtlogo, psconvert
# Step-1. Generate a file
ps=GMT_NNgrid_MT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN dimgray \
    MAP_FRAME_WIDTH 0.1c \
    MAP_TITLE_OFFSET 1.0c \
    MAP_ANNOT_OFFSET 0.1c \
    MAP_TICK_PEN_PRIMARY thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY thin,dimgray \
    MAP_GRID_PEN_SECONDARY thinnest,dimgray \
    FONT_TITLE 12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY 7p,Palatino-Roman,dimgray \
    FONT_LABEL 7p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Download data:
### http://topex.ucsd.edu/cgi-bin/get_data.cgi
## E-144-162;N40-51.
# Step-5. Examine the table
gmt info topo_MT.xyz
# output: topo_MT.xyz: N = 3815189    <120.0083/160.0083>    <5.002/30.0019>    <-10913/3559>
# Step-6. Convert ASCII to binary
gmt convert topo_MT.xyz -bo > topo_MT.b
# Step-7. Gridding using a nearest neighbor technique which is a local method: No output is given where there are no data.
region=`gmt info topo_MT.b -I1 -bi3d`
gmt nearneighbor $region -I10m -S40k -Gtopo_NN_MT.nc topo_MT.b -bi
# Step-8. Add contour lines
gmt grdcontour topo_NN_MT.nc -R120/160/5/30 -JM6i -P -C1000 -A2000+f6p,Times-Roman -Gd2i -K > $ps
# Step-9. Add coastline
gmt pscoast -R -J -P \
    -Bpxg4f2a4 -Bpyg4f2a4 -Bsxg2 -Bsyg2 -Df -Wthinnest \
    -B+t"Grid contour modelling using Nearest Neighbor algorithm. Mariana Trench area" \
    -TdjBR+w0.4i+l+o0.15i \
    -Lx13.0c/-1.1c+c50+w800k+l"Mercator projection, Scale, km"+f \
    -UBL/-15p/-35p -O -K >> $ps
# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0c -Y1.5c -N -O -K \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.0 14.0 Input table data: global 1-min grid resolution in ASCII XYZ-format, converted to binary
EOF
# Step-11. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.3c/-1.0c+w2c -O >> $ps
# Step-12. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert GMT_NNgrid_MT.ps -A0.2c -E720 -Tj -P -Z
