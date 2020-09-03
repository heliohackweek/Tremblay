pro prep_wavelets

;Silvina Guidoni
;;August 28, 2020

;To debug 
;.compile "/Users/guidoni/OneDrive\ -\ american.edu/Travel/Helio_hack_week/Wavelets/kconvol"
;.compile "/Users/guidoni/OneDrive\ -\ american.edu/Travel/Helio_hack_week/Wavelets/prep_wavelets"

;find fits
dir_find = "/Users/guidoni/OneDrive\ -\ american.edu/Travel/Helio_hack_week/Wavelets/fits/EIT/"
cd, dir_find
;save fits
dir_save = "/Users/guidoni/OneDrive\ -\ american.edu/Travel/Helio_hack_week/Wavelets/fits/EIT_kconv/"

w=file_search('*.fits') 
files = w
files = files(sort(files))
;count files
iiidx = where(files ne '', ct)
if (ct gt 0) then files = files(iiidx)
nn = n_elements(files)

;masks
mask = shift(dist(2048,2048),1024,1024)
mask_idx = where(mask gt 800)

;kernel
k = [[1,1,1],[1,3,1],[1,1,1]]

for q = 0,nn-1 do begin
  print, ' -----------------------------: ', q, nn-1

  print, ' Processing...:', files(q)
  
  ;read prepped fits
  img = READFITS( files(q), outhdr, /NOSCALE)
  
  ;apply transformations from original "general_full_cadence.pro"
  img = alog(img>0.01)
  img_orig = img

  img = sigma_filter(img,radius=3,/iterate)
  img(mask_idx) = (sigma_filter(img,radius=13,/iterate))(mask_idx)

  ;apply kernel
  mr = kconvol(img,30)
  for t=0,50 do mr = kconvol(mr,30)

  img1 = kconvol(img,k,total(k))
  img1 = kconvol(img1,k,total(k))
  l0 = kconvol(img1,k,total(k))

  c =  (img1-mr*.9^2.5 + (img1-l0)*12. )
  d = img/((img-c)>25) >1<2
  e = c*d^.5
  e_sin_label = e

  ;this was used to create pngs in the original"general_full_cadence.pro", but it is not used here
  e(where(mask gt 1030)) = 0
  
  writefits, dir_save + 'EIT_kconv_' + files(q), e_sin_label, outhdr

endfor

end
