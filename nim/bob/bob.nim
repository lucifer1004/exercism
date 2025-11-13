import strutils, sequtils

proc hey*(s: string): string =
  let msg = s.strip
  
  if msg.len == 0:
    return "Fine. Be that way!"
  
  let hasLetters = msg.anyIt(it.isAlphaAscii)
  let isShouting = hasLetters and msg == msg.toUpper
  let isQuestion = msg.endsWith("?")
  
  if isShouting and isQuestion:
    return "Calm down, I know what I'm doing!"
  elif isShouting:
    return "Whoa, chill out!"
  elif isQuestion:
    return "Sure."
  else:
    return "Whatever."
