print("Unix time now:"..time())
local today=time()
local dateTbl = {
	year = 2025,
	month = 12,
	day = 24,
}
print("Unix time now:"..time(dateTbl))
print("test :"..date("%m/%d/%y %H:%M:%S",today))
local temp= {
    name=GetCharname(),
    time=time(),
    session_time=0
}