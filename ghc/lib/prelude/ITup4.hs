module PreludeBuiltin where

--- 4-tuples ------------------------------------------

import Cls
import Core
import IChar
import IInt
import IList
import List		( (++), foldr )
import Prel		( (&&), (.) )
import PS		( _PackedString, _unpackPS )
import Text
import TyArray
import TyComplex

instance (Eq a, Eq b, Eq c, Eq d) => Eq (a,b,c,d) where
    (a1,a2,a3,a4) == (b1,b2,b3,b4) = a1 == b1 && a2 == b2 && a3 == b3 && a4 == b4
    aaaa          /= bbbb          = if (aaaa == bbbb) then False else True

instance (Ord a, Ord b, Ord c, Ord d) => Ord (a,b,c,d) where
    a <  b  = case _tagCmp a b of { _LT -> True;  _EQ -> False; _GT -> False }
    a <= b  = case _tagCmp a b of { _LT -> True;  _EQ -> True;  _GT -> False }
    a >= b  = case _tagCmp a b of { _LT -> False; _EQ -> True;  _GT -> True  }
    a >  b  = case _tagCmp a b of { _LT -> False; _EQ -> False; _GT -> True  }

    max a b = case _tagCmp a b of { _LT -> b; _EQ -> a;  _GT -> a }
    min a b = case _tagCmp a b of { _LT -> a; _EQ -> a;  _GT -> b }

    _tagCmp (a1, b1, c1, d1) (a2, b2, c2, d2)
      = case (_tagCmp a1 a2) of {
	  _LT -> _LT;
	  _GT -> _GT;
	  _EQ -> case _tagCmp b1 b2 of {
		      _LT -> _LT;
		      _GT -> _GT;
		      _EQ -> case _tagCmp c1 c2 of {
				  _LT -> _LT;
				  _GT -> _GT;
				  _EQ -> _tagCmp d1 d2
				}
		    }
	}

instance  (Ix a1, Ix a2, Ix a3, Ix a4) => Ix (a1,a2,a3,a4)  where
    range ((l1,l2,l3,l4),(u1,u2,u3,u4)) =
        [(i1,i2,i3,i4) | i1 <- range (l1,u1),
                         i2 <- range (l2,u2),
                         i3 <- range (l3,u3),
                         i4 <- range (l4,u4)]

    index ((l1,l2,l3,l4),(u1,u2,u3,u4)) (i1,i2,i3,i4) =
      index (l4,u4) i4 + rangeSize (l4,u4) * (
       index (l3,u3) i3 + rangeSize (l3,u3) * (
         index (l2,u2) i2 + rangeSize (l2,u2) * (
           index (l1,u1) i1)))
      where
	rangeSize (l,u) = index (l,u) u + (1 :: Int)

    inRange ((l1,l2,l3,l4),(u1,u2,u3,u4)) (i1,i2,i3,i4) =
        inRange (l1,u1) i1 && inRange (l2,u2) i2 &&
           inRange (l3,u3) i3 && inRange (l4,u4) i4

-- ToDo: something for Binary

instance (Text a, Text b, Text c, Text d) => Text (a, b, c, d) where
    readsPrec p = readParen False
		    (\a -> [((w,x,y,z), j) | ("(",b) <- lex a,
					     (w,c)   <- readsPrec 0 b,
					     (",",d) <- lex c,
					     (x,e)   <- readsPrec 0 d,
					     (",",f) <- lex e,
					     (y,g)   <- readsPrec 0 f,
					     (",",h) <- lex g,
					     (z,i)   <- readsPrec 0 h,
					     (")",j) <- lex i ] )

    showsPrec p (w,x,y,z) = showChar '(' . showsPrec 0 w . showString ", " .
					   showsPrec 0 x . showString ", " .
					   showsPrec 0 y . showString ", " .
					   showsPrec 0 z . showChar ')'

    readList	= _readList (readsPrec 0)
    showList	= _showList (showsPrec 0) 

{-# SPECIALIZE instance Eq   (Int,Int,Int,Int) #-}
{-# SPECIALIZE instance Ord  (Int,Int,Int,Int) #-}

#if defined(__UNBOXED_INSTANCES__)

-- We only create SPECIALIZED instances unboxed tuples
-- which have all the same unboxed component

-- {-# SPECIALIZE instance Eq   (Char#,Char#,Char#,Char#) #-}
-- {-# SPECIALIZE instance Ord  (Char#,Char#,Char#,Char#) #-}
-- {-# SPECIALIZE instance Ix   (Char#,Char#,Char#,Char#) #-}
-- {-# SPECIALIZE instance Text (Char#,Char#,Char#,Char#) #-}

-- {-# SPECIALIZE instance Eq   (Int#,Int#,Int#,Int#) #-}
-- {-# SPECIALIZE instance Ord  (Int#,Int#,Int#,Int#) #-}
-- {-# SPECIALIZE instance Ix   (Int#,Int#,Int#,Int#) #-}
-- {-# SPECIALIZE instance Text (Int#,Int#,Int#,Int#) #-}

-- {-# SPECIALIZE instance Eq   (Double#,Double#,Double#,Double#) #-}
-- {-# SPECIALIZE instance Ord  (Double#,Double#,Double#,Double#) #-}
-- {-# SPECIALIZE instance Text (Double#,Double#,Double#,Double#) #-}

#endif
