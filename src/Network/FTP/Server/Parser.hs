{- arch-tag: FTP protocol parser for servers
Copyright (C) 2004 John Goerzen <jgoerzen@complete.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-}

{- |
   Module     : Network.FTP.Server.Parser
   Copyright  : Copyright (C) 2004 John Goerzen
   License    : GNU LGPL, version 2.1 or above

   Maintainer : John Goerzen <jgoerzen@complete.org> 
   Stability  : provisional
   Portability: systems with networking

This module provides a parser that is used internally by
"Network.FTP.Server".  You almost certainly do not want to use
this module directly.  Use "Network.FTP.Server" instead.

Written by John Goerzen, jgoerzen\@complete.org

-}

module Network.FTP.Server.Parser(
                                         parseCommand
                                        )
where
import Network.FTP.Client.Parser
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Utils
import Data.List.Utils
import Data.Bits.Utils
import Data.String.Utils
import System.Log.Logger
import Network.Socket(SockAddr(..), PortNumber(..), inet_addr, inet_ntoa)
import System.IO(Handle, hGetContents)
import System.IO(hGetLine)
import Text.Regex
import Data.Word
import Data.Char

logit :: String -> IO ()
logit m = debugM "Network.FTP.Server.Parser" ("FTP received: " ++ m)

----------------------------------------------------------------------
-- Utilities
----------------------------------------------------------------------

alpha = oneOf (['A'..'Z'] ++ ['a'..'z']) <?> "alphabetic character"

word = many1 alpha

args :: Parser String
args = try (do char ' '
               r <- many anyChar
               eof 
               return r)
       <|> return ""
       

command :: Parser (String, String)
command = do
          x <- word
          y <- args
          eof
          return (map toUpper x, y)


parseCommand :: Handle -> IO (Either ParseError (String, String))
parseCommand h =
    do input <- hGetLine h
       return $ parse command "(unknown)" (rstrip input)
