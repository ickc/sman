function s
  if test "$argv[1]" = "run" -o "$argv[1]" = "r"
    eval (sman $argv)
  else
    sman $argv
  end
end
