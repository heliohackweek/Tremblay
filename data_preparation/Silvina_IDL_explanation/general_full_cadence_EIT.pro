pro general_full_cadence_eit, zz, wlength, month=month,  $
                               start=start, finish = finish,  $
                               yyyy=yyyy

; CALLING:
; 	general_full_cadence, 'A', '171', month='01', yyyy='2011', start=1, finish=10 


;****
;[SEG] = Silvina Guidoni
;Oct 13, 2020
;zz = 'A' or 'B' 
;wlength = '171'
;month= '01'
;yyyy='2011'
;start=1
;finish=10

;To debug
;.compile "/Users/guidoni/OneDrive\ -\ american.edu/Travel/Helio_hack_week/Wavelets/general_full_cadence_eit"
;.compile what_euvi
;****

;----------------------
;SEG code:
;find original fits
dir_find = "/Users/guidoni/OneDrive\ -\ american.edu/Travel/Helio_hack_week/Wavelets/fits/EIT/"
cd, dir_find
;find new fits
dir_save = "/Users/guidoni/OneDrive\ -\ american.edu/Travel/Helio_hack_week/Wavelets/fits/EIT_kconv/"
;----------------------

;****
;[SEG]:
;directory to find fits
;****
;................................................
;Original code:
;rootDir = getenv('secchi') +'/wavelets/'
;................................................

;****
;[SEG]:
;make directories where to save fits
;****
;................................................
;Original code:
;dir_save = rootDir
;spawn, 'mkdir ' + dir_save + 'fits/' + yyyy+month 
;spawn, 'mkdir ' + dir_save + 'pngs/' + yyyy+month 
;;spawn, 'mkdir ' + dir_save + 'fits/' + yyyy+month + '/' + wlength + '_' + zz
;;spawn, 'mkdir ' + dir_save + 'pngs/' + yyyy+month + '/' + wlength + '_' + zz
;................................................
 
;****
;[SEG]:
;The DIST function creates an array in which each array element value is proportional to its frequency.
;/Applications/harris/idl87/lib
;more dist.pro
;Returns an (N,M) floating array
;Result = DIST(N [, M])
; INPUTS:
;       N = number of columns in result.
;       M = number of rows in result.  If omitted, N is used to return
;               a square array.
;R(i,j) = SQRT(F(i)^2 + G(j)^2)   where:
;                F(i) = i  IF 0 <= i <= n/2
;                     = n-i  IF i > n/2
;                G(i) = i  IF 0 <= i <= m/2
;                     = m-i  IF i > m/2
;shift: shifts elements of vectors or arrays along any dimension by any number of elements. 
;Positive shifts are to the right while left shifts are expressed as a negative number. 
;All shifts are circular. 
;Result = SHIFT(Array, S1, ..., Sn)
;The result is a vector or array of the same structure and type as Array. 
;The Si arguments are the shift parameters applied to the n-th dimension
;NOt sure what this does. I think it chosses pixels inside solar radius
;Why 800 for mask_idx? 
;mask_idx is a long array
;****

;................................................
;Original code:
;mask = shift(dist(2048,2048),1024,1024)
;mask_idx = where(mask gt 800) 
;................................................

;----------------------
;SEG code:
fulldim = 2048
fulldim_half = fulldim/2
maxmask = 800
mask = shift(dist(fulldim,fulldim),fulldim_half,fulldim_half)
;mask outside a circle (not sure if it is solar radius yet)
mask_idx = where(mask gt maxmask)
;................................................

;----------------------
;SEG code:
;test masks
aaa = dist(fulldim,fulldim)
imgsize = size(aaa)
aaaplot = IMAGE(aaa , IMAGE_DIMENSIONS=[imgsize(1),imgsize(2)], DIMENSIONS=[512,512], MARGIN=0)
maskplot = IMAGE(mask , IMAGE_DIMENSIONS=[imgsize(1),imgsize(2)], DIMENSIONS=[512,512], MARGIN=0)
;binary mask that represents whether any given pixel was 
;below (0) or above (1) the calculated threshold value, effectively turning the input into a binary image.
result = IMAGE_THRESHOLD(mask , THRESHOLD=maxmask)
maskplot = IMAGE(result , IMAGE_DIMENSIONS=[imgsize(1),imgsize(2)], DIMENSIONS=[512,512], MARGIN=0)
;----------------------
;
;****
;[SEG]:
;fetch file paths?
;****
;................................................
;Original code:

;timerange = ['0000','2400']
;for t = start, finish do begin 
;      strday = strcompress(string(t),/rem)
;      strday = strmid('00',0,2-strlen(strday)) + strday
;           print, 'mkdir ' + dir_save + 'pngs/' + yyyy+month + '/' + strday + '/' + wlength + '_' + zz
;           spawn, 'mkdir ' + dir_save + 'pngs/' + yyyy+month + '/' + strday
;              spawn, 'mkdir ' + dir_save + 'pngs/' + yyyy+month + '/' + strday + '/' + wlength + '_' + zz
;           spawn, 'mkdir ' + dir_save + 'fits/' + yyyy+month + '/' + strday
;              spawn, 'mkdir ' + dir_save + 'fits/' + yyyy+month + '/' + strday + '/' + wlength + '_' + zz
;           
;      day = yyyy + month + strday   
      ;****
      ;[SEG]:
      ;Get a list of selected images. will return an IDL structure of string
      ;               arrays with filenames and absolute path of selected images
      ;****
;     w = what_euvi(day, timerange, sc=zz, wlength = wlength)
;      if (t eq start) then files = w else files = [files, w]
; endfor

;----------------------
;SEG code:
;search for fits
w=file_search('*.fits')
files = w
;----------------------

;****
;[SEG]:
;String arrays are sorted using the ASCII collating sequence.
;****
;................................................
;Original code:
 files = files(sort(files))
 ;................................................
 
 ;****
 ;[SEG]:
 ;count files (they should be the same
 ;****
 ;................................................
 ;Original code:
 iiidx = where(files ne '', ct)
 if (ct gt 0) then files = files(iiidx)
 nn = n_elements(files)
 ;****

 ;****
 ;[SEG]:
 ;choose view left or rigth?
 ;****
 ;................................................
 ;Original code:
 ;if (zz eq 'A') then view = 'R'
 ;if (zz eq 'B') then view = 'L'
 ;****
 
 ;****
 ;[SEG]:
 ;kernel, low pass filter with weight in center pixel?
 ; reducing the high frequency information (reduce noise)
 ;****
 ;................................................
 ;Original code:
 k = [[1,1,1],[1,3,1],[1,1,1]]
 ;................................................
 
 ;****
 ;[SEG]:
 ;for each found file, do
 ;****
for q = 0,nn-1 do begin
      print, ' -----------------------------: ', q, nn-1

      ;****
      ;[SEG]:
      ;prep stereo fits
      ;output image as "img"
      ;read in and perform the latest calibration and image correction procedures for all SECCHI instruments
      ;outsize=(1024 or 512)
      ;note: the default value of outsize is the largest image processed; outsize must be an integer factor of 2048?
      ;outhdr : headers
      ;/CALIMG_OFF: Do not apply vignetting or flat-field calibration
      ;/ROTATE_ON: the images are rotated to solar north. 
      ;The difference between solar north and ecliptic north changes though out the year. 
      ;CUBIC (maybe, not sure) = Interpolation parameter for cubic interpolation.
      ;                          See the IDL documentation for POLY_2D for more
      ;                          information.
      ;****
      ;................................................
      ;Original code:
      print, ' Processing...:', files(q)
      ;secchi_prep, files(q), outhdr, img, outsize = 2048, $
      ;                       /rotate_on, /calimg_off , /cubic
      ;................................................
             
       
      ;----------------------
      ;SEG code:     
      ;read already prepped fits
      ;output image as "img" is DOUBLE = Array[1024, 1024]
      ;It does not force  output size to be 2048 as requested above. Issue?
      ;/NOSCALE: the ouput data will not be scaled using the optional BSCALE and BZERO keywords 
      ;          in the FITS header. Default is to scale.
      ;physical value = BSCALE * (storage value) + BZERO
      ;BSCALE and BZERO are stored as keywords of the same names in the header of the same Header Data Unit (HDU). 
      ;The most common use of a scaled image is to store unsigned 16-bit integer 
      ; data because the FITS standard does not allow it. In this case, the stored data is signed 
      ; 16-bit integer (BITPIX=16) with BZERO=32768 (2^15) BSCALE=1.
      img = READFITS( files(q), outhdr, /NOSCALE)
      imgsize = size(img)
      print, "image size (should be 1024 x 1024:", imgsize(1),imgsize(2)
      ;implot = IMAGE(img , IMAGE_DIMENSIONS=[imgsize(1),imgsize(2)], DIMENSIONS=[512,512], MARGIN=0)
      ;----------------------
      
      ;****
      ;[SEG]:
      ;take log of image of pixels above 0.01.
      ;What happens to nan, zero, missing, or negative values?
      ;save log image in img_orig
      ;
      ;****
      ;................................................
      ;Original code:
      img = alog(img>0.01)
      img_orig = img
      ;................................................
      
      ;****
      ;[SEG]:
      ;sigma_filter: Replace pixels more than a specified pixels deviant from its neighbors 
      ;RADIUS = alternative to specify box radius, so box_width = 2*radius+1
      ;N_sigma = # standard deviations to define outliers, floating point,
      ;     recommend > 2, default = 3. For gaussian statistics:
      ;     N_sigma = 1 smooths 35% of pixels, 2 = 5%, 3 = 1%.
      ;/ITERATE causes sigma_filter to be applied recursively (max = 20 times)
      ;     until no more pixels change (only allowed when N_sigma >= 2).

      
       
     
      ;Replace pixels more than a specified pixels deviant from its neighbors
      ;Computes the mean and standard deviation of pixels in a box centered at
      ; each pixel of the image, but excluding the center pixel. If the center
      ; pixel value exceeds some # of standard deviations from the mean, it is
      ; replaced by the mean in box. Note option to process pixels on the edges.
      ; 
            
      ;imgsize = size(img)
      ;implot = IMAGE(img , IMAGE_DIMENSIONS=[imgsize(1),imgsize(2)], DIMENSIONS=[512,512], MARGIN=0)
      ;use bigger boxcar again only for pixels outside circle chosen by mask
      
      ;****
      ;................................................
      ;Original code:
      img = sigma_filter(img,radius=3,/iterate)
      ;****
      ;[SEG]:
      ;use bigger boxcar again only for pixels outside circle chosen by mask
      img(mask_idx) = (sigma_filter(img,radius=13,/iterate))(mask_idx)
      ;................................................ 
 
      ;----------------------
      ;SEG code: (to test differences)
      ;img_filt = sigma_filter(img,radius=3,/iterate)
      ;img_filt(mask_idx) = (sigma_filter(img_filt,radius=13,/iterate))(mask_idx)
      ;---------------------- 
       
      ;****
      ;[SEG]:
      ;create sigma-filtered of log image and smooth it 52 times with boxcar of 30 
      ;supersmooth
      ;; smooth boxcar of log image
      ; Edges are processed because padding is added
      ; Compute mean over moving box-cars using smooth, subtract center values,
      ; compute variance using smooth on deviations from mean,
      ; check where pixel deviation from mean is within variance of box,
      ; replace those pixels in smoothed image (mean) with orignal values,
      ; return the resulting partial mean image.

      ;****
       mr = kconvol(img,30)
       for t=0,50 do mr = kconvol(mr,30)
       
       ;****
       ;[SEG]:
       ;create sigma-filtered of log image and convolve with kernel twice       
       img1 = kconvol(img,k,total(k)) 
       img1 = kconvol(img1,k,total(k)) 
       ;create sigma-filtered of log image and convolve with kernel thrice
       l0 = kconvol(img1,k,total(k))

       ;****
       ;[SEG]:
       ;construct c:
       ;subtract twice kernel with dimmed (by ~0.77) supersmooth, enhance by 12 subtraction of twice kernel with trice kernel, add both
       c =  (img1-mr*.9^2.5 + (img1-l0)*12. )   
       ;****
       ;[SEG]:
       ;construct d:
       ;(img-c)>25, find maximum between img-c and 25
       ;divide sigma-filtered of log image by that maximum
       ;keep resulting pixels between 1 and 2       
       d = img/((img-c)>25) >1<2   
       ;****
       ;[SEG]:
       ;construct e:  
       ;take sqrt of d and multiply it by c
       e = c*d^.5
       ;image without labels (used to write fits)
       e_sin_label = e
       
       ;make zero pixels outside a larger circle than the original mask circle in the final image
       ;This is the final image, but later on it gets processed differently for each 
       ;wavelength when writing png, scaling by hard coded minmax and using different color tables 
       e(where(mask gt 1030)) = 0
       
       dhm =  strmid(files(q),strlen(files(q))-25,15)
       PUT_TEXT, e,TEXTARRAY('EUVI ' + strupcase(zz) + ' ('+wlength+'): ' +dhm +' UT',charsize =5,charthick=2,font=1),.02,.01,/NORMAL
       file_save_fits = strmid(files(q),strlen(files(q))-25,16)+wlength+'eu_'+view+'.fts' 
       ddd = strmid(files(q),strlen(files(q))-19,2)
        if zz eq 'A' then file_save_fits = dir_save + 'fits/' + strmid(day,0,6) + '/' + ddd + '/' + wlength+'_A/'+file_save_fits
        if zz eq 'B' then file_save_fits = dir_save + 'fits/' + strmid(day,0,6) + '/' + ddd + '/' + wlength+'_B/'+file_save_fits
        ; if zz eq 'A' then file_save_fits = dir_save + 'fits/' + strmid(day,0,6) + '/' + strmid(day,6,2) + '/' + wlength+'_A/'+file_save_fits
        ; if zz eq 'B' then file_save_fits = dir_save + 'fits/' + strmid(day,0,6) + '/' + strmid(day,6,2) + '/' + wlength+'_B/'+file_save_fits
     
       ;sccwritefits, '/Volumes/Disk2/dummy.fts', e_sin_label, outhdr
       sccwritefits, file_save_fits, e_sin_label, outhdr
       spawn, 'gzip ' + file_save_fits
       ;spawn, 'mv /Volumes/Disk2/dummy.fts.gz ' + file_save_fits + '.gz'
 
       file_save = strmid(files(q),strlen(files(q))-25,16)+wlength+'eu_'+view+'.png'   
       if zz eq 'A' then file_save = dir_save + 'pngs/' + strmid(day,0,6) +'/' + ddd + '/' + wlength+'_A/'+file_save
       if zz eq 'B' then file_save = dir_save + 'pngs/' + strmid(day,0,6) +'/' + ddd + '/' + wlength+'_B/'+file_save
       ; if zz eq 'A' then file_save = dir_save + 'pngs/' + strmid(day,0,6) +'/' + strmid(day,6,2) + '/' + wlength+'_A/'+file_save
       ; if zz eq 'B' then file_save = dir_save + 'pngs/' + strmid(day,0,6) +'/' + strmid(day,6,2) + '/' + wlength+'_B/'+file_save
   
       ;****
       ;[SEG]:
       ;Result = BYTSCL( Array [, MAX=value] [, MIN=value] [, /NAN] [, TOP=value] )
       ;bytscl: scales all values of Array that lie in the range (Min≤x≤Max) into the range (0 ≤x≤Top). 
       ;bytscl: scale using formula: (Top + 0.9999) * (x - Min)/(Max - Min). 
       ;If TOP is not specified, 255 is used. Note that the minimum value of the scaled result is always 0.
       ;byte: An 8-bit unsigned integer ranging in value from 0 to 255. Pixels in images are commonly represented as byte data.
   
       if (wlength eq '304') then begin
          eit_colors, 304
          tvlct, /get, rr, gg, bb
          write_png, file_save, bytscl(e,-1.0,3.6), rr, gg, bb
          loadct, 0
       endif

       if (wlength eq '284') then begin
          eit_colors, 284
          tvlct, /get, rr, gg, bb
          write_png, file_save, bytscl(e,-1.75,3.9), rr, gg, bb
          loadct, 0
       endif

       if (wlength eq '195') then begin
          eit_colors, 195
          tvlct, /get, rr, gg, bb
          write_png, file_save, bytscl(e,-1.7,3.8), rr, gg, bb
          loadct, 0
       endif

       if (wlength eq '171') then begin
          loadct, 0                  
          ;eit_colors, 171
          tvlct, /get, rr, gg, bb
          rr = (1.5*rr-150)>0<255
          gg = (gg+10)<255      
          bb = (bb+130)<255
          write_png, file_save, bytscl((e>0.01)^0.8,0.25,2.75), rr, gg, bb
          loadct, 0
       endif

 
    nada:
    
  endfor     
finnada:
;****


end
