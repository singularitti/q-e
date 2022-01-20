!
! Copyright (C) 2001-2022 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!----------------------------------------------------------------------------
! Author: Ivan Carnimeo (September 2021)
!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------
program band_interpolation 
use globalmod,         ONLY : card_user_stars, card_roughness, read_xml_input, t, build_kpath, at, bg, &
                                ek,  eq, Nb, Nq, NSym, q, Op, print_bands, deallocate_global
use idwmod,            ONLY : idw, p_metric, scale_sphere 
use fouriermod,        ONLY : fourier, miller_max, check_periodicity, RoughC, RoughN, NUser
use fourierdiffmod,    ONLY : fourierdiff
use input_parameters,  ONLY : k_points , xk, nkstot 
use parser,            ONLY : read_line
USE mp_global,         ONLY : mp_startup
USE io_global,         ONLY : stdout
USE read_cards_module, ONLY : card_kpoints 
implicit none
  !
  integer, parameter :: iunit = 5
  integer :: ios
  integer :: i, iii, ik
  CHARACTER(len=256)         :: input_line
  LOGICAL                    :: tend
  CHARACTER(len=80)          :: card
  CHARACTER(len=1), EXTERNAL :: capital
  !
  CHARACTER(len=80) :: method = ' '
  !! a string describing the method used for interpolation  
  !
  NAMELIST / interpolation / method, miller_max, check_periodicity, p_metric, scale_sphere
  !
  !
  write(*,*) 'PROGRAM: band_interpolation '
  !
#if defined(__MPI)
  CALL mp_startup ( )
#endif
  !
  ! Set defaults 
  !  
  method = 'fourier-diff'
  check_periodicity = .false.
  p_metric = 2
  scale_sphere = 4.0d0
  miller_max = 6  
  RoughN = 1  
  allocate( RoughC(RoughN) )
  RoughC(1) = 1.0d0
  NUser = 0 
  k_points = 'none'
  !
  ! Read input file
  !
  ios = 0 
  READ( iunit, interpolation, iostat = ios ) 
  !
100   CALL read_line( input_line, end_of_file=tend )
  !
  IF( tend ) GOTO 120
  IF( input_line == ' ' .OR. input_line(1:1) == '#' .OR. &
                             input_line(1:1) == '!' ) GOTO 100
  !
  READ (input_line, *) card
  !
  DO i = 1, len_trim( input_line )
     input_line( i : i ) = capital( input_line( i : i ) )
  ENDDO
  !
  IF ( trim(card) == 'ROUGHNESS' ) THEN
     !
     CALL card_roughness( input_line )
     !
  ELSEIF ( trim(card) == 'USER_STARS' ) THEN
     !
     CALL card_user_stars( input_line )
     !
  ELSEIF ( trim(card) == 'K_POINTS' ) THEN
     !
     CALL card_kpoints( input_line )
     !
  ELSE
     !
     WRITE( *,'(A)') 'Warning: card '//trim(input_line)//' ignored'
     !
  ENDIF
  !
  GOTO 100
  !
120  CONTINUE
  !
  if(k_points.ne.'tpiba') then 
    write(stdout,'(A,A)') 'k_points = ', k_points 
    Call errore('band_interpolation ' , ' K_POINTS card must be specified with tpiba_b ', 1)
  end if
  !
  if(nkstot.le.0) then 
    write(stdout,'(A,I5)') 'nkstot = ', nkstot
    Call errore('band_interpolation ' , ' wrong number of k-points ', 1)
  end if 
  !
  Write(stdout,'(A,A)') 'Interpolation method: ', method
  if( TRIM(method).ne.'idw'.and.TRIM(method).ne.'idw-sphere'&
        .and.TRIM(method).ne.'fourier'.and.TRIM(method).ne.'fourier-diff' ) &  
        Call errore('band_interpolation', 'Wrong interpolation method ', 1) 
  !
  ! Build the abscissa values for band plotting
  !
  allocate( t(nkstot) )
  t = 0.0d0
  do ik= 2, nkstot
    t(ik) = t(ik-1) + sqrt(dot_product(xk(:,ik)-xk(:,ik-1),xk(:,ik)-xk(:,ik-1)))
    write(*,'(I5,f12.6)') ik, t(ik)
  end do 
  !
  ! Read xml file
  !
  Call read_xml_input ()
  !
  ek = 0.0d0
  !
  if(TRIM(method).eq.'idw') then 
    !
    Call idw (1, Nb, Nq, q, eq, nkstot, xk, ek, at, bg)
    !
  elseif(TRIM(method).eq.'idw-sphere') then 
    !
    Call idw (2, Nb, Nq, q, eq, nkstot, xk, ek, at, bg)
    !
  elseif(TRIM(method).eq.'fourier') then 
    !
    Call fourier (Nb, Nq, q, eq, nkstot, xk, ek, Nsym, at, bg, Op)
    !
  elseif(TRIM(method).eq.'fourier-diff') then 
    !
    Call fourierdiff (Nb, Nq, q, eq, nkstot, xk, ek, Nsym, at, bg, Op)
    !
  else
    !
    write(*,*) 'ERROR: Wrong method ', TRIM(method)
    stop
    !
  end if
  !
  Call print_bands (TRIM(method))
  !
  Call deallocate_global ()
  !
end program
!----------------------------------------------------------------------------
