-- testfile


print("Unix time now:"..time())
local today=time()
local dateTbl = {
	year = 2025,
	month = 12,
	day = 24,
}
print("Unix time now:"..time(dateTbl))
test=date("*t",today)
--print("test :"..date("*t",today))
print(time({year=test.year, month=test.month, day=test.day}))
