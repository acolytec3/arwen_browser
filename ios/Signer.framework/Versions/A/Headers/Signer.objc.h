// Objective-C API for talking to psssign/gomobile_pss_signer Go package.
//   gobind -lang=objc psssign/gomobile_pss_signer
//
// File is generated by gobind. Do not edit.

#ifndef __Signer_H__
#define __Signer_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


FOUNDATION_EXPORT NSData* _Nullable SignerSign(NSData* _Nullable rawTransaction, NSString* _Nullable n, NSString* _Nullable d, NSString* _Nullable dp, NSString* _Nullable dq, NSError* _Nullable* _Nullable error);

#endif
