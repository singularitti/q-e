MODULE fft_buffers
  !
  USE fft_param
  IMPLICIT NONE
  SAVE
  !
  INTEGER :: current_size = 0
  COMPLEX(DP), ALLOCATABLE :: dev_space_fftparallel(:)
  COMPLEX(DP), ALLOCATABLE :: pin_space_scatter_in(:)
  COMPLEX(DP), ALLOCATABLE :: pin_space_scatter_out(:)
#if defined(__CUDA)
  attributes(DEVICE) :: dev_space_fftparallel
  attributes(PINNED) :: pin_space_scatter_in
  attributes(PINNED) :: pin_space_scatter_out
#endif
  !
  PUBLIC :: check_buffers_size, deallocate_buffers
  !
CONTAINS
  !
  SUBROUTINE check_buffers_size( desc, howmany )
    USE fft_types,      ONLY : fft_type_descriptor
    TYPE(fft_type_descriptor), INTENT(in) :: desc
    INTEGER, OPTIONAL, INTENT(IN) :: howmany
    INTEGER :: howmany_
    INTEGER :: info

    IF (PRESENT(howmany)) THEN
      howmany_ = howmany
    ELSE
      howmany_ = 1
    ENDIF
    !
    IF (current_size < desc%nnr * howmany_) THEN
      !
      current_size = desc%nnr * howmany_
      !
      IF( ALLOCATED( dev_space_fftparallel ) ) DEALLOCATE( dev_space_fftparallel )
      IF( ALLOCATED( pin_space_scatter_in  ) ) DEALLOCATE( pin_space_scatter_in  )
      IF( ALLOCATED( pin_space_scatter_out ) ) DEALLOCATE( pin_space_scatter_out )
      !
      ALLOCATE(dev_space_fftparallel(current_size), STAT=info)
      IF ( info /= 0 ) CALL fftx_error__( ' fft_buffers ', ' Allocation failed ', 1 )
      ALLOCATE(pin_space_scatter_in (current_size), STAT=info)
      IF ( info /= 0 ) CALL fftx_error__( ' fft_buffers ', ' Allocation failed ', 2 )
      ALLOCATE(pin_space_scatter_out(current_size), STAT=info)
      IF ( info /= 0 ) CALL fftx_error__( ' fft_buffers ', ' Allocation failed ', 3 )
      !
    END IF
    !
  END SUBROUTINE check_buffers_size
  !
  SUBROUTINE deallocate_buffers()
    current_size = 0
    IF( ALLOCATED( dev_space_fftparallel ) ) DEALLOCATE( dev_space_fftparallel )
    IF( ALLOCATED( pin_space_scatter_in  ) ) DEALLOCATE( pin_space_scatter_in  )
    IF( ALLOCATED( pin_space_scatter_out ) ) DEALLOCATE( pin_space_scatter_out )
  END SUBROUTINE deallocate_buffers

END MODULE fft_buffers
