{-# OPTIONS_GHC -fno-warn-type-defaults #-}

import Data.Ix           (inRange)
import Test.Hspec        (Spec, describe, it, shouldBe, shouldSatisfy)
import Test.Hspec.Runner (configFastFail, defaultConfig, hspecWith)

import Robot (mkRobot, resetName, robotName)

main :: IO ()
main = hspecWith defaultConfig {configFastFail = True} specs

{-
These tests of course *can* fail since we are expected to use a random number
generator. The chances of this kind of failure are very small. A
real "robot generator" would use a proper serial number system and
would likely not be in the business of resetting the name.
-}
specs :: Spec
specs = describe "robot-name" $ do

          -- As of 2016-07-30, there was no reference file
          -- for the test cases in `exercism/x-common`.

          let a = ('A', 'Z')
          let d = ('0', '9')
          let matchesPattern s = length s == 5
                                 && and (zipWith inRange [a, a, d, d, d] s)

          -- `shouldNotBe` is not availabe on lts-2.22.
          let x `shouldNotBe` y = x `shouldSatisfy` (/= y)

          it "name should match expected pattern" $
            mkRobot >>= robotName >>= (`shouldSatisfy` matchesPattern)

          it "name is persistent" $ do
            r <- mkRobot
            n1 <- robotName r
            n2 <- robotName r
            n3 <- robotName r
            n1 `shouldBe` n2
            n1 `shouldBe` n3

          it "different robots have different names" $ do
            n1 <- mkRobot >>= robotName
            n2 <- mkRobot >>= robotName
            n1 `shouldNotBe` n2

          it "new name should match expected pattern" $ do
            r <- mkRobot
            resetName r
            robotName r >>= (`shouldSatisfy` matchesPattern)

          it "new name is persistent" $ do
            r <- mkRobot
            resetName r
            n1 <- robotName r
            n2 <- robotName r
            n3 <- robotName r
            n1 `shouldBe` n2
            n1 `shouldBe` n3

          it "new name is different from old name" $ do
            r <- mkRobot
            n1 <- robotName r
            resetName r
            n2 <- robotName r
            n1 `shouldNotBe` n2

          it "resetting a robot affects only one robot" $ do
            r1 <- mkRobot
            r2 <- mkRobot
            n1 <- robotName r1
            n2 <- robotName r2
            n1 `shouldNotBe` n2
            resetName r1
            n1' <- robotName r1
            n2' <- robotName r2
            n1' `shouldNotBe` n2'
            n2  `shouldBe`    n2'
