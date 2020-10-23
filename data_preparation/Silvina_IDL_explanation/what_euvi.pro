function what_euvi, day, time_range, sc = sc, wlength=wlength

;CALLING:
; files = what_euvi('20080110', ['1455','2055'], sc='A', wlength = '195')

;****
;[SEG]:
; scclister: Get a list of selected images. will return an IDL structure of string
;               arrays with filenames and absolute path of selected images
;'SSR1' for synoptic images and 'SSR2' for special event sequences
;****
  w = scclister(day,'EUVI', sc=sc, polar=wlength, dest='SSR1')

 if (size(w))(0) ne 0 then begin
     ;****
     ;[SEG]:
     ;tag_exist: To test whether a tag name exists in a structure. 
     ;****
     dda1 = tag_exist(w,'sc_a')
     ddb1 = tag_exist(w,'sc_b')

     if sc eq 'A' and dda1 then files = w.sc_a
     if sc eq 'B' and ddb1 then files = w.sc_b
  endif

;  if sc eq 'A' then files = w.sc_a
;  if sc eq 'B' then files = w.sc_b

; -----------------------------------------
  w = scclister(day,'EUVI', sc=sc, polar=wlength, dest='SSR2')
 
  if (size(w))(0) ne 0 then begin
     dda = tag_exist(w,'sc_a')
     ddb = tag_exist(w,'sc_b')
 
     if sc eq 'A' and dda then files = [files, w.sc_a]
     if sc eq 'B' and ddb then files = [files, w.sc_b]
  endif
  
  if (n_elements(files) gt 2) then begin
     files = files(sort(files)) 
  endif else begin
      files = ''
      goto, nada
  endelse
  
; -----------------------------------------

  times = strmid(files, strlen(files(0))-25 , 13)
  time0 = day + '_' + time_range(0)
  time1 = day + '_' + time_range(1)
  
  idx = where(times ge time0 and times le time1)
  files = files(idx)
  
  print, files
  help, files
  
nada:
  return, files

end
