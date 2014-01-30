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
#include "dub/dub.h"

#define TIME_SCALE 1000000000.0

#ifdef __APPLE__ && __MACH__

//#include <CoreServices/CoreServices.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>
#include <stdio.h>

static double sConvert;

void lub::initTimeRef() {
  mach_timebase_info_data_t time_base_info;
  mach_timebase_info(&time_base_info);
  // numer/denom converts to nanoseconds. We divide by 10^9 to have seconds
  sConvert = (double)time_base_info.numer / time_base_info.denom / TIME_SCALE;
}

double lub::elapsed() {
  return sConvert * mach_absolute_time();
}

#elif _WIN32 || __WIN32__

#include <windows.h>

static double sConvert;

void lub::initTimeRef() {
  sConvert = 0.0;

  LARGE_INTEGER lpFrequency;
  if (!QueryPerformanceCounter(&lpFrequency))
    throw dub::Exception("Cannot retrieve performance counter frequency.");

  sConvert = 1.0 / lpFrequency;
}

double lub::elapsed() {
  LARGE_INTEGER lpPerformanceCount;
  if (!QueryPerformanceCounter(&lpPerformanceCount))
    throw dub::Exception("Cannot retrieve performance counter value.");

  return sConvert * lpPerformanceCount;
}

#else

#include <time.h> // clock_gettime

void lub::initTimeRef() {
  // noop
}

double lub::elapsed() {
  timespec t;
  clock_gettime(CLOCK_MONOTONIC, &t);
  return t.tv_sec + (t.tv_nsec / TIME_SCALE);
}

#endif

