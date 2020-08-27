pro general_full_cadence_eit, wlength, month=month,  $
  start=start, finish = finish,  $
  yyyy=yyyy, download=download

  ; CALLING:
  ;   general_full_cadence, 'A', '171', month='01', yyyy='2011', start=1, finish=10

  ; EIM edit: added /download option to retrieve and sort files from VSO if needed

  if (not_exist(getenv('SSW_EIT') +'/wavelets/') eq 0) then spawn,'mkdir '+getenv('SSW_EIT') +'/wavelets/'
  rootDir = getenv('SSW_EIT') +'/wavelets/'

  dir_save = rootDir
  if (not_exist(dir_save + 'fits') eq 0) then spawn, 'mkdir ' + dir_save + 'fits' 
  if (not_exist(dir_save + 'fits/' + yyyy+month) eq 0) then spawn, 'mkdir ' + dir_save + 'fits/' + yyyy+month

  if (not_exist(dir_save + 'pngs') eq 0) then spawn, 'mkdir ' + dir_save + 'pngs'
  if (not_exist(dir_save + 'pngs/' + yyyy+month) eq 0) then spawn, 'mkdir ' + dir_save + 'pngs/' + yyyy+month
  ;spawn, 'mkdir ' + dir_save + 'fits/' + yyyy+month + '/' + wlength + '_' + zz
  ;spawn, 'mkdir ' + dir_save + 'pngs/' + yyyy+month + '/' + wlength + '_' + zz

  ;begin EIM edits
  ; This section I added downloads a few representative files from each day and places them in
  ; directories that keep the wavelengths separate (something you can't do by filename alone with SECCHI).
  ; This ensures that the pngs output at the end are properly sorted and colored.
  if keyword_set(download) then begin
    tmpdir='$SSW_EIT/lz/L0/img/eit/'+yyyy+month
    if (not_exist(tmpdir) eq 0) then spawn,'mkdir '+tmpdir
    cd,tmpdir
    if (not_exist(tmpdir+'/'+wlength) eq 0) then spawn,'mkdir '+wlength
    for t=fix(start),fix(finish) do begin
      a=vso_search(date='2011/08/'+strtrim(t,2)+'T00:00-2011/08/0'+strtrim(t,2)+'T23:59',$
        inst='eit',wave=wlength+' Angstrom')
      b=vso_get(a)
    endfor
    ff=file_search('efz'+yyyy+month+'*')
    for j=0,n_elements(ff)-1 do spawn,'mv '+ff[j]+' $SSW_EIT/lz/L0/img/eit/'+yyyy+month+'/'+wlength
    endif
  ;end EIM edits

  mask = shift(dist(1024,1024),1024,1024)
  mask_idx = where(mask gt 400)

  timerange = ['0000','2400']
  for t = fix(start), fix(finish) do begin
    strday = strcompress(string(t),/rem)
    strday = strmid('00',0,2-strlen(strday)) + strday
    if (not_exist(dir_save + 'pngs/' + yyyy+month + '/' + strday + '/' + wlength) eq 0) then $
      print, 'mkdir ' + dir_save + 'pngs/' + yyyy+month + '/' + strday + '/' + wlength
    if (not_exist(dir_save + 'pngs/' + yyyy+month + '/' + strday) eq 0) then $
      spawn, 'mkdir ' + dir_save + 'pngs/' + yyyy+month + '/' + strday
    if (not_exist(dir_save + 'pngs/' + yyyy+month + '/' + strday + '/' + wlength) eq 0) then $
      spawn, 'mkdir ' + dir_save + 'pngs/' + yyyy+month + '/' + strday + '/' + wlength
    if (not_exist(dir_save + 'fits/' + yyyy+month + '/' + strday) eq 0) then $
      spawn, 'mkdir ' + dir_save + 'fits/' + yyyy+month + '/' + strday
    if (not_exist(dir_save + 'fits/' + yyyy+month + '/' + strday + '/' + wlength) eq 0) then $
      spawn, 'mkdir ' + dir_save + 'fits/' + yyyy+month + '/' + strday + '/' + wlength

    day = yyyy + month + strday
    ; begin EIM edits (removing dependence on summary files, no longer easily available)
    ;w = what_euvi(day, timerange, sc=zz, wlength = wlength)
    w=file_search('$SSW_EIT/lz/L0/img/eit/'+yyyy+month+'/'+wlength,'efz'+day+'.*')
    if (t eq start) then files = w else files = [files, w]
  endfor
  files = files(sort(files))


  iiidx = where(files ne '', ct)
  if (ct gt 0) then files = files(iiidx)
  nn = n_elements(files)

  k = [[1,1,1],[1,3,1],[1,1,1]]

  for q = 0,nn-1 do begin
    if files[q] eq '' then begin
      print, 'No file available -- check directory!'
      return
    endif
    print, ' -----------------------------: ', q, nn-1

    print, ' Processing...:', files[q]
    eit_prep, files[q], outhdr, img, outsize = 2048, $
      /rotate_on, /calimg_off , /cubic,/no_calibrate

    img = alog(img>0.01)
    img_orig = img

    img = sigma_filter(img,radius=3,/iterate)
    img(mask_idx) = (sigma_filter(img,radius=13,/iterate))(mask_idx)

    mr = kconvol(img,30)
    for t=0,50 do mr = kconvol(mr,30)

    img1 = kconvol(img,k,total(k))
    img1 = kconvol(img1,k,total(k))
    l0 = kconvol(img1,k,total(k))

    c =  (img1-mr*.9^2.5 + (img1-l0)*12. )
    d = img/((img-c)>25) >1<2
    e = c*d^.5
    e_sin_label = e

    e(where(mask gt 1030)) = 0

    ;dhm =  strmid(files[q],strlen(files[q])-25,15)
    ;PUT_TEXT, e,TEXTARRAY('EUVI ' + strupcase(zz) + ' ('+wlength+'): ' +dhm +' UT',charsize =5,charthick=2,font=1),.02,.01,/NORMAL
    ;xyouts,.02,.01,'EUVI ' + ' ('+wlength+'): ' +dhm +' UT',charsize=5,charthick=2,font=1
    ;file_save_fits = strmid(files[q],strlen(files[q])-25,16)+wlength+'eit.fts'
    file_save_fits = files[q].substring(53,-1)+wlength+'eit.fts'
    ddd = strmid(files[q],strlen(files[q])-19,2)
    file_save_fits = dir_save + 'fits/' + strmid(day,0,6) + '/' + strmid(day,6,2) + '/' + wlength+'/'+file_save_fits
    
    ;sccwritefits, '/Volumes/Disk2/dummy.fts', e_sin_label, outhdr
    writefits, file_save_fits, e_sin_label, outhdr
    spawn, 'gzip ' + file_save_fits
 
    file_save = files[q].substring(53,-1)+wlength+'eit.png'
    file_save = dir_save + 'pngs/' + strmid(day,0,6) +'/' + strmid(day,6,2) + '/' + wlength+'/'+file_save

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

end