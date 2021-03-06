module mod_client
!  Licensing:
!    This code is distributed under the GNU LGPL license.
!  Modified:
!    Nov 2016
!  Author:
!    Salvador Rodríguez-Gómez
 implicit none
 private
 integer,parameter             :: maxlinelength = 80
 integer,parameter             :: ga_size       = 1000
 type                          :: typ_client
  character(len=maxlinelength) :: names, added_date,mail,phone,company
  integer                      :: id
  real                         :: priority
  logical                      :: flag_asigned_to_room
  integer                      :: room_asigned,room_constrained
 end type
 type(typ_client), pointer     :: asigned(:)
 type(typ_client), pointer     :: noasigned(:)
 type(typ_client), target      :: pop_alpha( ga_size )
 type(typ_client), target      :: pop_beta(  ga_size )
 contains
  subroutine Swap()
   if (associated(asigned, target=pop_alpha)) then
    asigned   => pop_beta
    noasigned => pop_alpha
   else
    asigned   => pop_alpha
    noasigned => pop_beta
   end if
   return
  end subroutine Swap
end module mod_client
!
module mod_CSV_io
!  Licensing:
!    This code is distributed under the GNU LGPL license.
!  Modified:
!    29 November 2008
!  Author:
!    John Burkardt
 implicit none
 private
 public csv_file_line_count, csv_file_open_read, csv_value_count, csv_file_close_read,timestamp
 public csv_record_append_i4
 contains
 subroutine csv_value_count ( csv_record, csv_record_status, value_count )
!! CSV_COUNT counts the number of values in a CSV record.
  implicit none
  character csv_char
  character csv_char_old
  integer ( kind = 4 ) csv_len
  integer ( kind = 4 ) csv_loc
  character ( len = * ) csv_record
  integer ( kind = 4 ) csv_record_status
  character :: TAB = achar ( 9 )
  integer ( kind = 4 ) value_count
  integer ( kind = 4 ) word_length
  value_count = 0
!  We begin in "unquoted" status.
  csv_record_status = 0
!  How many characters in the record?
  csv_len = len_trim ( csv_record )
!  Count number of characters in each word.
  word_length = 0
!  Consider each character.
  csv_char_old = ','
  do csv_loc = 1, csv_len
    csv_char = csv_record(csv_loc:csv_loc)
!  Each comma divides one value from another.
    if ( csv_char_old == ',' ) then
      value_count = value_count + 1
      word_length = 0
!  For quotes, try using CSV_RECORD_STATUS to count the number of
!  quoted characters.
    else if ( csv_char == '"' ) then
      if ( 0 < csv_record_status ) then
        csv_record_status = 0
      else
        csv_record_status = csv_record_status + 1
      end if
!  Ignore blanks
    else if ( csv_char == ' ' .or. csv_char == TAB ) then
!  Add character to length of word.
    else
      word_length = word_length + 1
      if ( value_count == 0 ) then
        value_count = 1
      end if
    end if
    csv_char_old = csv_char
  end do
  return
end
subroutine csv_file_close_read ( csv_file_name, csv_file_unit )
!! CSV_FILE_CLOSE_READ closes a CSV file for reading.
!    Input, character ( len = * ) CSV_FILE_NAME, the name of the file.
!    Input, integer ( kind = 4 ) CSV_FILE_UNIT, the unit number
  implicit none
  character ( len = * ) csv_file_name
  integer ( kind = 4 ) csv_file_unit
  close ( unit = csv_file_unit )
  return
end
subroutine csv_file_close_write ( csv_file_name, csv_file_unit )
!! CSV_FILE_CLOSE_WRITE closes a CSV file for writing.
!    Input, character ( len = * ) CSV_FILE_NAME, the name of the file.
!    Input, integer ( kind = 4 ) CSV_FILE_UNIT, the unit number
  implicit none
  character ( len = * ) csv_file_name
  integer ( kind = 4 ) csv_file_unit
  close ( unit = csv_file_unit )
  return
end
subroutine csv_file_header_write ( csv_file_name, csv_file_unit, header )
!! CSV_FILE_HEADER_WRITE writes a header to a CSV file.
!    Input, character ( len = * ) CSV_FILE_NAME, the name of the file.
!    Input, integer ( kind = 4 ) CSV_FILE_UNIT, the unit number
!    Input, character ( len = * ) HEADER, the header.
  implicit none
  character ( len = * ) csv_file_name
  integer ( kind = 4 ) csv_file_unit
  character ( len = * ) header
  write ( csv_file_unit, '(a)' ) trim ( header )
  return
end
subroutine csv_file_line_count ( csv_file_name, line_num )
!! CSV_FILE_LINE_COUNT counts the number of lines in a CSV file.
!    This routine does not try to distinguish the possible header line,
!    blank lines, or cases where a single CSV record extends over multiple 
!    lines.  It simply counts the number of lines.
!    Input, character ( len = * ) CSV_FILE_NAME, the name of the file.
!    Output, integer ( kind = 4 ) LINE_NUM, the number of lines.
  implicit none
  character ( len = * ) csv_file_name
  integer ( kind = 4 ) ierror
  integer ( kind = 4 ) input_status
  integer ( kind = 4 ) input_unit
  character ( len = 1023 ) line
  integer ( kind = 4 ) line_num
  line_num = -1
  call get_unit ( input_unit )
  open ( unit = input_unit, file = csv_file_name, status = 'old', &
    iostat = input_status )
  if ( input_status /= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'CSV_FILE_LINE_COUNT - Fatal error!'
    write ( *, '(a,i8)' ) '  Could not open "' // trim ( csv_file_name ) // '".'
    stop
  end if
  line_num = 0
  do
    read ( input_unit, '(a)', iostat = input_status ) line
    if ( input_status /= 0 ) then
      ierror = line_num
      exit
    end if
    line_num = line_num + 1
  end do
  close ( unit = input_unit )
  return
end
subroutine csv_file_record_write ( csv_file_name, csv_file_unit, record )
!! CSV_FILE_RECORD_WRITE writes a record to a CSV file.
!    Input, character ( len = * ) CSV_FILE_NAME, the name of the file.
!    Input, integer ( kind = 4 ) CSV_FILE_UNIT, the unit number
!    Input, character ( len = * ) RECORD, the record.
  implicit none
  character ( len = * ) csv_file_name
  integer ( kind = 4 ) csv_file_unit
  character ( len = * ) record
  write ( csv_file_unit, '(a)' ) trim ( record )
  return
end
subroutine csv_file_open_read ( csv_file_name, csv_file_unit )
!! CSV_FILE_OPEN_READ opens a CSV file for reading.
!    Input, character ( len = * ) CSV_FILE_NAME, the name of the file.
!    Output, integer ( kind = 4 ) CSV_FILE_UNIT, the unit number
  implicit none
  character ( len = * ) csv_file_name
  integer ( kind = 4 ) csv_file_status
  integer ( kind = 4 ) csv_file_unit
  call get_unit ( csv_file_unit )
  open ( unit = csv_file_unit, file = csv_file_name, status = 'old', &
    iostat = csv_file_status )
  if ( csv_file_status /= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'CSV_FILE_OPEN_READ - Fatal error!'
    write ( *, '(a,i8)' ) '  Could not open "' // trim ( csv_file_name ) // '".'
    csv_file_unit = - 1
    stop
  end if
  return
end
subroutine csv_file_open_write ( csv_file_name, csv_file_unit )
!! CSV_FILE_OPEN_WRITE opens a CSV file for writing.
!    Input, character ( len = * ) CSV_FILE_NAME, the name of the file.
!    Output, integer ( kind = 4 ) CSV_FILE_UNIT, the unit number
  implicit none
  character ( len = * ) csv_file_name
  integer ( kind = 4 ) csv_file_status
  integer ( kind = 4 ) csv_file_unit
  call get_unit ( csv_file_unit )
  open ( unit = csv_file_unit, file = csv_file_name, status = 'replace', &
    iostat = csv_file_status )
  if ( csv_file_status /= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'CSV_FILE_OPEN_WRITE - Fatal error!'
    write ( *, '(a,i8)' ) '  Could not open "' // trim ( csv_file_name ) // '".'
    stop
  end if
  return
end
subroutine csv_record_append_i4 ( i4, record )
!! CSV_RECORD_APPEND_I4 appends an I4 to a CSV record.
!    Input, integer ( kind = 4 ) I4, the integer to be appended
!    Input/output, character ( len = * ) RECORD, the CSV record.
  implicit none
  character ( len = 5 ) fmat
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i4
  integer ( kind = 4 ) i4_len
  character ( len = * ) record
  i = len_trim ( record )
!  Append comma.
  if ( 0 < i ) then
    i = i + 1
    record(i:i) = ','
  end if
!  Determine "width" of I4.
  i4_len = i4_width ( i4 )
!  Create format for I4.
  write ( fmat, '(a,i2,a)' ) '(i', i4_len, ')'
!  Write I4 to RECORD.
  write ( record(i+1:i+i4_len), fmat ) i4
  return
end
subroutine csv_record_append_r4 ( r4, record )
!! CSV_RECORD_APPEND_R4 appends an R4 to a CSV record.
!    Input, real ( kind = 8 ) R4, the value to be appended
!    Input/output, character ( len = * ) RECORD, the CSV record.
  implicit none
  character ( len = 5 ) fmat
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i4
  integer ( kind = 4 ) i4_len
  real ( kind = 4 ) r4
  character ( len = * ) record
!  Locate last used location in RECORD.
  i = len_trim ( record )
!  Append comma.
  if ( 0 < i ) then
    i = i + 1
    record(i:i) = ','
  end if
  if ( r4 == 0.0E+00 ) then
    i = i + 1
    record(i:i) = '0'
  else if ( r4 == real ( int ( r4 ), kind = 4 ) ) then
    i4 = int ( r4 )
    i4_len = i4_width ( i4 )
    write ( fmat, '(a,i2,a)' ) '(i', i4_len, ')'
    write ( record(i+1:i+i4_len), fmat ) i4
  else
    write ( record(i+1:i+14), '(g14.6)' ) r4
  end if
  return
end
subroutine csv_record_append_r8 ( r8, record )
!! CSV_RECORD_APPEND_R8 appends an R8 to a CSV record.
!    Input, real ( kind = 8 ) R8, the value to be appended
!    Input/output, character ( len = * ) RECORD, the CSV record.
  implicit none
  character ( len = 5 ) fmat
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i4
  integer ( kind = 4 ) i4_len
  !integer ( kind = 4 ) i4_width
  real ( kind = 8 ) r8
  character ( len = * ) record
!  Locate last used location in RECORD.
  i = len_trim ( record )
!  Append comma.
  if ( 0 < i ) then
    i = i + 1
    record(i:i) = ','
  end if
  if ( r8 == 0.0D+00 ) then
    i = i + 1
    record(i:i) = '0'
  else if ( r8 == real ( int ( r8 ), kind = 8 ) ) then
    i4 = int ( r8 )
    i4_len = i4_width ( i4 )
    write ( fmat, '(a,i2,a)' ) '(i', i4_len, ')'
    write ( record(i+1:i+i4_len), fmat ) i4
  else
    write ( record(i+1:i+14), '(g14.6)' ) r8
  end if
  return
end
subroutine csv_record_append_s ( s, record )
!! CSV_RECORD_APPEND_S appends a string to a CSV record.
!    Input, character ( len = * ) S, the string to be appended
!    Input/output, character ( len = * ) RECORD, the CSV record.
  implicit none
  integer ( kind = 4 ) i
  character ( len = * ) record
  character ( len = * ) s
  integer ( kind = 4 ) s_len
!  Locate last used location in RECORD.
  i = len_trim ( record )
!  Append a comma.
  if ( 0 < i ) then
    i = i + 1
    record(i:i) = ','
  end if
!  Prepend a quote.
  i = i + 1
  record(I:i) = '"'
!  Write S to RECORD.
  s_len = len_trim ( s )
  record(i+1:i+s_len) = s(1:s_len)
  i = i + s_len
!  Postpend a quote
  i = i + 1
  record(i:i) = '"'
  return
end
subroutine get_unit ( iunit )
!! GET_UNIT returns a free FORTRAN unit number.
  implicit none
  integer ( kind = 4 ) i
  integer ( kind = 4 ) ios
  integer ( kind = 4 ) iunit
  logical lopen
  iunit = 0
  do i = 1, 99
    if ( i /= 5 .and. i /= 6 .and. i /= 9 ) then
      inquire ( unit = i, opened = lopen, iostat = ios )
      if ( ios == 0 ) then
        if ( .not. lopen ) then
          iunit = i
          return
        end if
      end if
    end if
  end do
  return
end
integer function i4_log_10 ( i )
!! I4_LOG_10 returns the integer part of the logarithm base 10 of an I4.
!    I4_LOG_10 ( I ) + 1 is the number of decimal digits in I.
!    An I4 is an integer ( kind = 4 ) value.
!  Example:
!        I  I4_LOG_10
!    -----  --------
!        0    0
!        1    0
!        2    0
!        9    0
!       10    1
!       11    1
!       99    1
!      100    2
!      101    2
!      999    2
!     1000    3
!     9999    3
!    10000    4
!    Input, integer ( kind = 4 ) I, the number whose logarithm base 10
!    is desired.
!    Output, integer ( kind = 4 ) I4_LOG_10, the integer part of the
!    logarithm base 10 of the absolute value of X.
  implicit none
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i_abs
  integer ( kind = 4 ) ten_pow
  if ( i == 0 ) then
    i4_log_10 = 0
  else
    i4_log_10 = 0
    ten_pow = 10
    i_abs = abs ( i )
    do while ( ten_pow <= i_abs )
      i4_log_10 = i4_log_10 + 1
      ten_pow = ten_pow * 10
    end do
  end if
  return
end
integer function i4_width ( i )
!! I4_WIDTH returns the "width" of an I4.
!    The width of an integer is the number of characters necessary to print it.
!    The width of an integer can be useful when setting the appropriate output
!    format for a vector or array of values.
!    An I4 is an integer ( kind = 4 ) value.
!  Example:
!        I  I4_WIDTH
!    -----  -------
!    -1234    5
!     -123    4
!      -12    3
!       -1    2
!        0    1
!        1    1
!       12    2
!      123    3
!     1234    4
!    12345    5
!    Input, integer ( kind = 4 ) I, the number whose width is desired.
!    Output, integer ( kind = 4 ) I4_WIDTH, the number of characters
!    necessary to represent the integer in base 10, including a negative
!    sign if necessary.
  implicit none
  integer ( kind = 4 ) i
  if ( 0 < i ) then
    i4_width = i4_log_10 ( i ) + 1
  else if ( i == 0 ) then
    i4_width = 1
  else if ( i < 0 ) then
    i4_width = i4_log_10 ( i ) + 2
  end if
  return
end
subroutine timestamp ( )
!! TIMESTAMP prints the current YMDHMS date as a time stamp.
!    31 May 2001   9:45:54.872 AM
  implicit none
  character ( len = 8 ) ampm
  integer ( kind = 4 ) d
  integer ( kind = 4 ) h
  integer ( kind = 4 ) m
  integer ( kind = 4 ) mm
  character ( len = 9 ), parameter, dimension(12) :: month = (/ &
    'January  ', 'February ', 'March    ', 'April    ', &
    'May      ', 'June     ', 'July     ', 'August   ', &
    'September', 'October  ', 'November ', 'December ' /)
  integer ( kind = 4 ) n
  integer ( kind = 4 ) s
  integer ( kind = 4 ) values(8)
  integer ( kind = 4 ) y
  call date_and_time ( values = values )
  y = values(1)
  m = values(2)
  d = values(3)
  h = values(5)
  n = values(6)
  s = values(7)
  mm = values(8)
  if ( h < 12 ) then
    ampm = 'AM'
  else if ( h == 12 ) then
    if ( n == 0 .and. s == 0 ) then
      ampm = 'Noon'
    else
      ampm = 'PM'
    end if
  else
    h = h - 12
    if ( h < 12 ) then
      ampm = 'PM'
    else if ( h == 12 ) then
      if ( n == 0 .and. s == 0 ) then
        ampm = 'Midnight'
      else
        ampm = 'AM'
      end if
    end if
  end if
  write ( *, '(i2,1x,a,1x,i4,2x,i2,a1,i2.2,a1,i2.2,a1,i3.3,1x,a)' ) &
    d, trim ( month(m) ), y, h, ':', n, ':', s, '.', mm, trim ( ampm )
  return
end
end module
!
module mod_random
 implicit none
 private
 public init_random_seed, randint, r4_uniform
 contains
!
 subroutine init_random_seed(seed)
  implicit none
  integer, intent(out) :: seed
  integer   day,hour,i4_huge,milli,minute,month,second,year
  parameter (i4_huge=2147483647)
  double precision temp
  character*(10) time
  character*(8) date
  call date_and_time (date,time)
  read (date,'(i4,i2,i2)')year,month,day
  read (time,'(i2,i2,i2,1x,i3)')hour,minute,second,milli
  temp=0.0D+00
  temp=temp+dble(month-1)/11.0D+00
  temp=temp+dble(day-1)/30.0D+00
  temp=temp+dble(hour)/23.0D+00
  temp=temp+dble(minute)/59.0D+00
  temp=temp+dble(second)/59.0D+00
  temp=temp+dble(milli)/999.0D+00
  temp=temp/6.0D+00
  doext: do
    if(temp<=0.0D+00 )then
       temp=temp+1.0D+00
       cycle doext
    else
       exit doext
    end if
  enddo doext
  doext2: do
    if (1.0D+00<temp) then
       temp=temp-1.0D+00
       cycle doext2
    else
       exit doext2
    end if
  end do doext2
  seed=int(dble(i4_huge)*temp)
  if(seed == 0)       seed = 1
  if(seed == i4_huge) seed = seed-1
  return
 end subroutine init_random_seed
!
 integer function randint(i,j,seed)
  real               ::  a,b
  integer,intent(in) ::  i,j,seed
  a = real(i)
  b = real(j)
  randint=int(r4_uniform(a,b+1.0,seed))
  return
 end function randint
!
 real function r4_uniform(b1,b2,seed)
  implicit none
  real b1,b2
  integer i4_huge,k,seed
  parameter (i4_huge=2147483647)
  if(seed == 0) then
   write(*,'(b1)')'R4_UNIFORM - Fatal error!'
   write(*,'(b1)')'Input value of SEED = 0.'
   stop '[ERROR]'
  end if
  k=seed/127773
  seed=16807*(seed-k*17773)-k*2836
  if(seed<0) then
    seed=seed+i4_huge
  endif
  r4_uniform=b1+(b2-b1)*real(dble(seed)* 4.656612875D-10)
  return
 end function r4_uniform
end module mod_random

module mod_input_output
 implicit none
 integer,parameter          :: maxlinelength = 80
 character(maxlinelength)   :: line
 integer                    :: err_apertura
 ! variable
 integer                    :: seed
 logical                    :: stop_flag = .false.
 logical                    :: seed_flag = .true.
 contains
!
 subroutine read_input()
 implicit none
 read_input_do: do 
  read(5,'(A)',iostat=err_apertura) line
  if( err_apertura /= 0 ) exit read_input_do
  if(line(1:1)=='#') cycle read_input_do
  if(line(1:5)=='STOP!')   stop_flag=.true.
 end do read_input_do
 rewind(5)
 end subroutine read_input
!
 subroutine ReadCSV()
  use mod_csv_io
  use mod_random
  implicit none
  character ( len = 80 ) :: csv_file_name = 'input.csv'
  integer   ( kind = 4 ) :: csv_file_status
  integer   ( kind = 4 ) :: csv_file_unit
  integer   ( kind = 4 ) :: csv_record_status
  integer   ( kind = 4 ) :: i,k = 0
  integer   ( kind = 4 ) :: line_num
  character ( len = 120 ):: record
  character ( len = 120 ):: string 
  integer   ( kind = 4 ) :: value_count
  !csv_file_line_count, csv_file_open_read, csv_value_count, csv_file_close_read
  call csv_file_line_count ( csv_file_name, line_num )
  write ( *, '(a,i8,a)' ) '  File contains ', line_num, ' lines.'
  call csv_file_open_read ( csv_file_name, csv_file_unit )
  read ( csv_file_unit, '(a)', iostat = csv_file_status ) record
  write(6,'(i5,2x,a)')1,trim(record)
  do i = 2, line_num
    read ( csv_file_unit, '(a)', iostat = csv_file_status ) record
    call csv_value_count ( record, csv_record_status, value_count )
    if(value_count>=k) k = value_count
    !write ( 6, '(a)' ) i, trim ( record )
    string=record
    !write(6,'(i5,2x,a)')i,record
    call csv_record_append_i4(randint(1,10,seed),string)
    write(6,'(i5,2x,a)')i,trim(string)
    write ( 6, * ) i, value_count
  end do
  call csv_file_close_read ( csv_file_name, csv_file_unit )
  return
 end subroutine ReadCSV
!
end module mod_input_output

program CRM
 use mod_random
 use mod_input_output
 use mod_client
 use mod_csv_io, only : timestamp
 !eterno_viajero: do while ( 1 > 0 )
  call read_input()
  if (seed_flag) then
   call init_random_seed(seed)
   write(6,'(a,1x,i20)')'Random Seed',seed
   seed_flag=.false.
  end if
  if(stop_flag) STOP 'CRM STOPPED'
  call ReadCSV()
 !end do eterno_viajero
 call timestamp()
end program CRM
