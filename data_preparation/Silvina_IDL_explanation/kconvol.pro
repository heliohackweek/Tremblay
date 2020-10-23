FUNCTION KCONVOL , A , KERNEL , SCALE_FACTOR , CENTER = center
;+
; NAME:
;	KCONVOL
;
; PURPOSE:
;	This program will smooth an array, including the edges,
;	using IDL's SMOOTH or CONVOL functions, by surrounding the array
;	with duplicates of itself and then convolving the larger
;	array.
;
; CALLING SEQUENCE:
;	Result = KCONVOL(A , KERNEL , SCALE_FACTOR , CENTER =)
;
; INPUTS:
;	A = the array you wish to smooth. It may be of any type.
;		May have one or two dimensions.
;
;	KERNEL = a 1D or 2D kernel, depending whether A is 1D or 2D.
;		IF KERNEL is a number, it is assumed to be the width of
;		the boxcar window of SMOOTH.
;
; OPTIONAL INPUTS:
;	SCALE_FACTOR = a scale factor for the convolution. See CONVOL.
;
; KEYWORDS:
;	CENTER = center the kernel over each array point. See CONVOL.
;
; KEYWORD PARAMETERS:
;	None.
;
; OUTPUTS:
;	Result = the smoothed array. Type is floating.
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	Straightforward. It is based on program SMOOTHE included in
;	H.Cohl's IDL library.
;	Unlike SCONVOL, KCONVOL does not assume any symmetry of the
;	kernel.
;
; MODIFICATION HISTORY:
;	H. Cohl, 23 Sep, 1991      --- Generalization (SMOOTHE)
;	K. Reardon, 19 Jun, 1991   --- Initial programming (SMOOTHE)
;	R. Molowny-Horas, Jan 1994 --- Modified to use less memory (SMOOTHE)
;	R. Molowny-Horas and Z. Yi, May 1994 --- Accepts any kind of kernel.
;-
;

;******
;SEG comment
;Control to be returned to the caller of a procedure in the event of an error. 
;The routine is exited as soon as an error occurs
;See Note on Smoothing Over Large Data Ranges
;https://www.l3harrisgeospatial.com/docs/SMOOTH.html#S_820040301_1082296
;A different way to compute the smoothed array is to use the SHIFT operation, 
; which won’t pollute the downstream values. 
; Maybe smoothing with median may be better?
;******

ON_ERROR,2
  ;******
  ;SEG comment:
  ;N_PARAMS function returns the number of parameters used in calling an IDL procedure or function. 
	;******
	IF N_PARAMS(0) LT 2 THEN MESSAGE,'Wrong input'
  
  ;******
	;SEG comment:
	; array and kernel should have same dimensions
	; size function:
	; 0: number of dimensions of Expression (value is zero if Expression is scalar or undefined)
	; 1 ... : size of each dimension, one element per dimension (none if Expression is scalar or undefined). 
	; n-1, n: type code (zero if undefined) and the number of elements in Expression, respectively.
	;******
	sk = SIZE(kernel)
	s = SIZE(a)
	IF sk(0) NE 0 THEN IF s(0) NE sk(0) THEN $
		MESSAGE,'Kernel and array must have some number of dimensions'

	IF N_ELEMENTS(scale_factor) EQ 0 THEN scale_factor = 1.
	IF N_ELEMENTS(center) EQ 0 THEN center = 1

	CASE 1 OF
		s(0) EQ 0: MESSAGE,' Input is not an array'
		s(0) EQ 1: GOTO,ONED
		s(0) EQ 2: GOTO,TWOD
		ELSE: MESSAGE,'Input array has more than two dimensions'
	ENDCASE

ONED:			;One dimensional array.

	IF sk(0) EQ 0 THEN wx = kernel ELSE wx = sk(1)
	
	;******
	;SEG comment:
	;create new array A with extra wx elements on each side.
	;copy A at the center of this array
	;NOZERO: inhibit zeroing of the array elements to execute faster.
	;******
	border = wx*2
	eg1 = s(1)+wx-1
	sa = FLTARR(border+s(1),/nozero)
	sa(wx:eg1) = a
	;******
	;SEG comment:
	;flip array 180 degrees
	;Transpose A with rotation Counterclockwise by 90 degrees
	;X1 = -X0, Y1=Y0, X1 = Nx - Y1 - 1
	;******
	a = ROTATE(a,5)
	;mirror A at the border in extra elements
	sa(0:wx-1) = a(s(1)-wx:s(1)-1)
	sa(s(1)+wx:s(1)+2*wx-1) = a(0:wx-1)
	;Flip A back to its original state
	a = ROTATE(a,5)
    ; Decia IF N_ELEMENTS(kernel) EQ 0 .....
    
  ;smoothed with a boxcar AVERAGE of the specified width. 
  ;borders are changed using the extra elements, otherwise
  ;smooth does not touch them 
	IF N_ELEMENTS(kernel) EQ 1 THEN sa = SMOOTH(sa,kernel) ELSE $
		sa = CONVOL(sa,kernel,scale_factor,center=center)
	;retrieve only central array (without extra elements)
	sa = sa(wx:eg1)
	GOTO,finishup

TWOD:			;Two dimensional array.

	IF s(1) EQ 1 THEN BEGIN
		a = a(*)
		GOTO,oned
	ENDIF

	IF sk(0) EQ 0 THEN BEGIN
		wx = kernel
		wy = kernel
	ENDIF ELSE BEGIN
		wx = sk(1)
		wy = sk(2)
	ENDELSE

	borderx = wx*2
	bordery = wy*2
	eg1 = s(1) + (wx-1)
	eg2 = s(2) + (wy-1)
	max1 = s(1) + borderx - 1
	max2 = s(2) + bordery - 1

  ;create array with extra padding 
	sa = FLTARR(borderx+s(1),bordery+s(2),/nozero)
	sa(wx:eg1,wy:eg2) = a
	;flip A horizontally
	a = ROTATE(a,5)
	;I
	sa(0:wx-1,wy:eg2) = a(s(1)-wx:s(1)-1,*)
	;II
	sa(s(1)+wx:max1,wy:eg2) = a(0:wx-1,*)
	;flip A vertically
	a = ROTATE(ROTATE(a,5),7)
	;III
	sa(wx:eg1,0:wy-1) = a(*,s(2)-wy:s(2)-1)
	;IV
	sa(wx:eg1,s(2)+wy:max2) = a(*,0:wy-1)
	;flip horizontally and then vertically
	a = ROTATE(ROTATE(a,7),2)
	;V
	sa(0:wx-1,0:wy-1) = a(s(1)-wx:s(1)-1,s(2)-wy:s(2)-1)
	;VI
	sa(s(1)+wx:max1,s(2)+wy:max2) = a(0:wx-1,0:wy-1)
	;VII
	sa(0:wx-1,s(2)+wy:max2) = a(s(1)-wx:s(1)-1,0:wy-1)
	;VIII
	sa(s(1)+wx:max1,0:wy-1) = a(0:wx-1,s(2)-wy:s(2)-1)
	;return to original A
	a = ROTATE(a,2)
	IF sk(0) EQ 0 THEN sa = SMOOTH(sa,kernel) ELSE $
		sa = CONVOL(sa,kernel,scale_factor,center=center)
	sa = sa(wx:eg1,wy:eg2)

	finishup:

	RETURN,sa

END
