!
! Copyright (C) 2007-2011 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!----------------------------------------------------------------------------
MODULE esm
  !--------------------------------------------------------------------------
  !! This module contains the variables and subroutines needed for the
  !! effective sreening medium (ESM) method (M. Otani and O.Sugino, Phys.
  !! Rev. B 73, 115407 (2006)).
  !
  !! Original version by Minoru Otani (AIST), Yoshio Miura (Tohoku U.),
  !! Nicephore Bonet (MIT), Nicola Marzari (MIT), Brandon Wood (LLNL),
  !! Tadashi Ogitsu (LLNL).
  !! Constant bias potential (constant-mu) method by Minoru Otani (AIST) and
  !! Nicephore Bonnet (AIST).
  !
  !! ESM enables description of a surface slab sandwiched between two
  !! semi-infinite media, making it possible to deal with polarized surfaces
  !! without using dipole corrections. It is useful for simulating interfaces
  !! with vacuum, one or more electrodes, or an electrolyte.
  !!
  !! esm_z_inv avoids finding an irrelevant inversion symmetry & phfact
  !! shifts the z-mesh by a half mesh when nr3 is even. (implemented by
  !! S. Nishihara)
  !!
  USE kinds, ONLY : DP
  USE esm_common_mod
  USE esm_hartree_mod
  USE esm_ewald_mod
  USE esm_local_mod
  USE esm_force_mod
  USE esm_stres_mod
  !
  IMPLICIT NONE
  !
  SAVE
  !
  PRIVATE
  !
  PUBLIC :: do_comp_esm, esm_nfit, esm_efield, esm_w, esm_a, esm_bc, &
            mill_2d, imill_2d, ngm_2d, &
            esm_init, esm_z_inv, esm_hartree, esm_local, esm_ewald, &
            esm_force_lc, esm_force_ew, &
            esm_stres_har, esm_stres_ewa, esm_stres_loclong, &
            esm_printpot, esm_summary
  !
  LOGICAL :: do_comp_esm = .FALSE.
  !
CONTAINS
  !
  ! Checks inversion symmetry along z-axis
  !
  LOGICAL FUNCTION esm_z_inv()
    !
    USE constants, ONLY : eps14
    !
    IMPLICIT NONE
    !
    esm_z_inv = .TRUE.
    !
    IF (do_comp_esm) THEN
      IF (TRIM(esm_bc) == 'bc1') THEN
        esm_z_inv = .TRUE.
      ELSE IF (TRIM(esm_bc) == 'bc2') THEN
        esm_z_inv = (ABS(esm_efield) < eps14)
      ELSE IF (TRIM(esm_bc) == 'bc3') THEN
        esm_z_inv = .FALSE.
      ELSE IF (TRIM(esm_bc) == 'bc4') THEN
        esm_z_inv = .FALSE.
      END IF
    END IF
    !
  END FUNCTION esm_z_inv
  !
END MODULE esm
