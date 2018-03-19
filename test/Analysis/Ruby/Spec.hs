module Analysis.Ruby.Spec (spec) where

import Data.Abstract.Value
import Data.Map

import SpecHelpers


spec :: Spec
spec = parallel $ do
  describe "evalutes Ruby" $ do
    it "require_relative" $ do
      env <- evaluate "main.rb"
      let expectedEnv = Environment $ fromList [ (qualifiedName ["foo"], addr 0) ]
      env `shouldBe` expectedEnv

    it "load" $ do
      env <- evaluate "load.rb"
      let expectedEnv = Environment $ fromList [ (qualifiedName ["foo"], addr 0) ]
      env `shouldBe` expectedEnv

    it "load wrap" $ do
      res <- evaluate' "load-wrap.rb"
      fst res `shouldBe` Left "free variable: \"foo\""
      snd res `shouldBe` Environment (fromList [ ])

  where
    addr = Address . Precise
    fixtures = "test/fixtures/ruby/analysis/"
    evaluate entry = snd <$> evaluate' entry
    evaluate' entry = fst . fst . fst . fst <$>
      evaluateFiles rubyParser
      [ fixtures <> entry
      , fixtures <> "foo.rb"
      ]
