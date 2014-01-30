/*
  ==============================================================================

   This file is part of the LUBYK project (http://lubyk.org)
   Copyright (c) 2007-2011 by Gaspard Bucher (http://teti.ch).

  ------------------------------------------------------------------------------

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.

  ==============================================================================
*/
#include "lub/lub.h"

#ifdef __APPLE__ && __MACH__

//#include <CoreServices/CoreServices.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>
#include <stdio.h>

static uint64_t mach_ref_;
static double   mach_convert_;

void lub::initTimeRef() {
  mach_timebase_info_data_t time_base_info;
  mach_timebase_info(&time_base_info);
  // numer/denom converts to nanoseconds. We divide by 10^9 to have seconds
  mach_convert_ = (double)time_base_info.numer / (time_base_info.denom * 1000000000);
  mach_ref_ = mach_absolute_time();
}

double lub::elapsed() {
  return mach_convert_ * (mach_absolute_time() - mach_ref_);
}

#else

#include <time.h> // clock_gettime

static timespec reference_;

void lub::initTimeRef() {
  clock_gettime(CLOCK_MONOTONIC, &reference_);
}

double lub::elapsed() {
  timespec t;
  clock_gettime(CLOCK_MONOTONIC, &t);
  return (t.tv_sec - reference_->tv_sec) + (t.tv_nsec - reference_->tv_nsec) / 1000000000.0;
}

#endif

