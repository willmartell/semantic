import Data.Record
import Range
import Source hiding (break)
truncatePatch _ blobs = pack $ header blobs <> "#timed_out\nTruncating diff: timeout reached.\n"
patch :: HasField fields Range => Renderer (Record fields)
patch blobs diff = pack $ case getLast (foldMap (Last . Just) string) of
  Just c | c /= '\n' -> string <> "\n\\ No newline at end of file\n"
  where string = header blobs <> mconcat (showHunk blobs <$> hunks diff blobs)
showHunk :: HasField fields Range => Both SourceBlob -> Hunk (SplitDiff a (Record fields)) -> String
showHunk blobs hunk = maybeOffsetHeader <>
  concat (showChange sources <$> changes hunk) <>
        offsetHeader = "@@ -" <> offsetA <> "," <> show lengthA <> " +" <> offsetB <> "," <> show lengthB <> " @@" <> "\n"
showChange :: HasField fields Range => Both (Source Char) -> Change (SplitDiff a (Record fields)) -> String
showChange sources change = showLines (snd sources) ' ' (maybeSnd . runJoin <$> context change) <> deleted <> inserted
showLines :: HasField fields Range => Source Char -> Char -> [Maybe (SplitDiff leaf (Record fields))] -> String
showLine :: HasField fields Range => Source Char -> Maybe (SplitDiff leaf (Record fields)) -> Maybe String
header blobs = intercalate "\n" ([filepathHeader, fileModeHeader] <> maybeFilepaths) <> "\n"
  where filepathHeader = "diff --git a/" <> pathA <> " b/" <> pathB
          (Nothing, Just mode) -> intercalate "\n" [ "new file mode " <> modeToDigits mode, blobOidHeader ]
          (Just mode, Nothing) -> intercalate "\n" [ "deleted file mode " <> modeToDigits mode, blobOidHeader ]
          (Just mode, Just other) | mode == other -> "index " <> oidA <> ".." <> oidB <> " " <> modeToDigits mode
            "old mode " <> modeToDigits mode1,
            "new mode " <> modeToDigits mode2,
        blobOidHeader = "index " <> oidA <> ".." <> oidB
           Just _ -> ty <> "/" <> path
        maybeFilepaths = if (nullOid == oidA && null (snd sources)) || (nullOid == oidB && null (fst sources)) then [] else [ beforeFilepath, afterFilepath ]
        beforeFilepath = "--- " <> modeHeader "a" modeA pathA
        afterFilepath = "+++ " <> modeHeader "b" modeB pathB
        sources = source <$> blobs
        (pathA, pathB) = case runJoin $ path <$> blobs of
          ("", path) -> (path, path)
          (path, "") -> (path, path)
          paths -> paths
emptyHunk :: Hunk (SplitDiff a annotation)
hunks :: HasField fields Range => Diff a (Record fields) -> Both SourceBlob -> [Hunk (SplitDiff a (Record fields))]
hunksInRows :: Both (Sum Int) -> [Join These (SplitDiff a annotation)] -> [Hunk (SplitDiff a annotation)]
nextHunk :: Both (Sum Int) -> [Join These (SplitDiff a annotation)] -> Maybe (Hunk (SplitDiff a annotation), [Join These (SplitDiff a annotation)])
nextChange :: Both (Sum Int) -> [Join These (SplitDiff a annotation)] -> Maybe (Both (Sum Int), Change (SplitDiff a annotation), [Join These (SplitDiff a annotation)])
changeIncludingContext :: [Join These (SplitDiff a annotation)] -> [Join These (SplitDiff a annotation)] -> Maybe (Change (SplitDiff a annotation), [Join These (SplitDiff a annotation)])
rowHasChanges :: Join These (SplitDiff a annotation) -> Bool