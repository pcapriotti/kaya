// Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.

#include <QImage>
#include <cmath>
#include <QPainter>

#include "extensions.h"

/*
struct ruby_object {
    bool allocated;
    Smoke* smoke;
    int classId;
    void* ptr;
};*/

template<int aprec, int zprec>
static inline void blurinner(unsigned char *bptr, int &zR,
                             int &zG, int &zB, int &zA, int alpha);

template<int aprec,int zprec>
static inline void blurrow(QImage & im, int line, int alpha);

template<int aprec, int zprec>
static inline void blurcol(QImage & im, int col, int alpha);

/*
 *  expblur(QImage &img, int radius)
 *
 *  In-place blur of image 'img' with kernel
 *  of approximate radius 'radius'.
 *
 *  Blurs with two sided exponential impulse
 *  response.
 *
 *  aprec = precision of alpha parameter
 *  in fixed-point format 0.aprec
 *
 *  zprec = precision of state parameters
 *  zR,zG,zB and zA in fp format 8.zprec
 */
template<int aprec,int zprec>
static void expblur(QImage &img, int radius )
{
    if (radius < 1)
        return;

    /* Calculate the alpha such that 90% of
       the kernel is within the radius.
       (Kernel extends to infinity)
    */
    int alpha = (int)((1<<aprec)*(1.0f-expf(-2.3f/(radius+1.f))));

    for(int row=0;row<img.height();row++) {
        blurrow<aprec,zprec>(img,row,alpha);
    }

    for(int col=0;col<img.width();col++) {
        blurcol<aprec,zprec>(img,col,alpha);
    }
    return;
}

template<int aprec, int zprec>
static inline void blurinner(unsigned char *bptr,
                             int &zR, int &zG, int &zB, int &zA, int alpha)
{
    int R,G,B,A;
    R = *bptr;
    G = *(bptr+1);
    B = *(bptr+2);
    A = *(bptr+3);

    zR += (alpha * ((R<<zprec)-zR))>>aprec;
    zG += (alpha * ((G<<zprec)-zG))>>aprec;
    zB += (alpha * ((B<<zprec)-zB))>>aprec;
    zA += (alpha * ((A<<zprec)-zA))>>aprec;

    *bptr =     zR>>zprec;
    *(bptr+1) = zG>>zprec;
    *(bptr+2) = zB>>zprec;
    *(bptr+3) = zA>>zprec;
}

template<int aprec,int zprec>
static inline void blurrow( QImage & im, int line, int alpha)
{
    int zR,zG,zB,zA;

    QRgb *ptr = (QRgb *)im.scanLine(line);

    zR = *((unsigned char *)ptr    )<<zprec;
    zG = *((unsigned char *)ptr + 1)<<zprec;
    zB = *((unsigned char *)ptr + 2)<<zprec;
    zA = *((unsigned char *)ptr + 3)<<zprec;

    for(int index=1; index<im.width(); index++) {
        blurinner<aprec,zprec>((unsigned char *)&ptr[index],
                               zR, zG, zB, zA, alpha);
    }
    for(int index=im.width()-2; index>=0; index--) {
        blurinner<aprec,zprec>((unsigned char *)&ptr[index],
                               zR, zG, zB, zA, alpha);
    }


}

template<int aprec, int zprec>
static inline void blurcol(QImage & im, int col, int alpha)
{
    int zR,zG,zB,zA;

    QRgb *ptr = (QRgb *)im.bits();
    ptr+=col;

    zR = *((unsigned char *)ptr    )<<zprec;
    zG = *((unsigned char *)ptr + 1)<<zprec;
    zB = *((unsigned char *)ptr + 2)<<zprec;
    zA = *((unsigned char *)ptr + 3)<<zprec;

    for(int index=im.width(); index<(im.height()-1)*im.width();
        index+=im.width()) {
        blurinner<aprec,zprec>((unsigned char *)&ptr[index],
                               zR, zG, zB, zA, alpha);
    }

    for(int index=(im.height()-2)*im.width(); index>=0;
        index-=im.width()) {
        blurinner<aprec,zprec>((unsigned char *)&ptr[index],
                               zR, zG, zB, zA, alpha);
    }

}

void Extensions::exp_blur(QImage* img, int radius) const {
  return expblur<15,7>(*img, radius);
}


/*
static ruby_object* get_object(VALUE val) {
  if (TYPE(val) != T_DATA) {
    return 0;
  }

  ruby_object* o = 0;
  Data_Get_Struct(val, ruby_object, o);
  return o;
}

extern "C" VALUE test_expblur(VALUE self, VALUE val, VALUE radius) {
  ruby_object* o = get_object(val);
  if (o) {
    QImage* img = (QImage*)o->smoke->cast(o->ptr, o->classId, o->smoke->idClass("QImage"));
    expblur<15,7>(*img, NUM2INT(radius));
  }
  
  return Qnil;
}

extern "C" void Init_expblur() {
  rb_define_method(Qnil, "expblur", (VALUE (*)(...))test_expblur, 2);
}*/
