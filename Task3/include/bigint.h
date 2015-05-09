#ifndef _HOMEWORK3_BIGINT_H
#define _HOMEWORK3_BIGINT_H
#include <stdint.h>
#include <stddef.h>

typedef void* BigInt;

#ifdef __cplusplus
extern "C" {
#endif


BigInt bInit(int64_t);
void bPush(BigInt *a, int64_t v);
void bPop(BigInt *a, int64_t v);

/** Create a BigInt from 64-bit signed integer.
 */
BigInt biFromInt(int64_t x);

/** Create a BigInt from a decimal string representation.
 *  Returns NULL on incorrect string.
 */
BigInt biFromString(char const *s);

/** Generate a decimal string representation from a BigInt.
 *  Writes at most limit bytes to buffer.
 */
void biToString(BigInt bi, char *buffer, size_t limit);

/**	:
*	
*/

void biToStringAsIs(BigInt bi, char *buffer);
/** Destroy a BigInt.
 */
void biDelete(BigInt bi);

/** Get sign of given BigInt.
 *  \return 0 if bi is 0, positive if bi is positive, negative if bi is negative.
 */
int biSign(BigInt bi);

void biAddMod(BigInt dst, BigInt src);
void biSubMod(BigInt dst, BigInt src);

/** dst += src */
void biAdd(BigInt dst, BigInt src);

/** dst -= src */
void biSub(BigInt dst, BigInt src);

/** dst *= src */
void biMul(BigInt dst, BigInt src);

/** Compute quotient and remainder by divising numerator by denominator.
 *  quotient * denominator + remainder = numerator
 *
 *  \param remainder must be in range [0, denominator) if denominator > 0
 *                                and (denominator, 0] if denominator < 0.
 */
void biDivRem(BigInt *quotient, BigInt *remainder, BigInt numerator, BigInt denominator);

/** Compare two BitInts.
 * \returns sign(a - b)
 */
int biCmp(BigInt a, BigInt b);

#ifdef __cplusplus
}
#endif

#endif
