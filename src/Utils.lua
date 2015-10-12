function print_r (t)
	print_r(t, print)
end

function print_r (t, out)
	local print_r_cache={}
	local function sub_print_r(t,indent)
		if (print_r_cache[tostring(t)]) then
			out(indent.."*"..tostring(t))
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					if (type(val)=="table") then
						out(indent.."["..pos.."] => "..tostring(t).." {")
						sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
						out(indent..string.rep(" ",string.len(pos)+6).."}")
					elseif (type(val)=="string") then
						out(indent.."["..pos..'] => "'..val..'"')
					else
						out(indent.."["..pos.."] => "..tostring(val))
					end
				end
			else
				out(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		out(tostring(t).." {")
		sub_print_r(t,"  ")
		out("}")
	else
		sub_print_r(t,"  ")
	end
	out()
end

