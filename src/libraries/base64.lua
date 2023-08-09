--$gooncreeper
--Implementation following RFC 4648
local Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local Pad      = "="

--Configuration end
--Quick encoding process:
--	We have two tables, one for the first two character of a 3 character subset and a
--	table for the last two characters of a 3 character subset that has the first two
--	and last two characters of the Base 64 encoding.

--	This works since the first two characters add up the first 16 bits which is enough
--	to know the first 12 bits of the character subset. Same for the last two characters,
--	we know the last 16 bits therefore we can determine the last 12 bits.

--	+ : First two data characters    (1 and 2)
--	% : Last two data characters     (2 and 3)
--	A : First two Base 64 characters (1 and 2)
--	B : Last two Base 64 characters  (3 and 4)

--		Illustration of bit overlaps:
--	AAAAAAAAAAAA
--	++++++++++++++++
--	            BBBBBBBBBBBB
--	        %%%%%%%%%%%%%%%%

--Quick decoding process:
--	This works essentially the same as the encoding process except we have three tables,
--	one for the first two Base 64 characters, the middle two, and the last two. Theoretically,
--	we could have a table for the first three and last two but that would take alot of
--	memory to store.

--	The table for the first two Base 64 characters will correspond to the first character, the
--	table for the middle two corresponds to the middle character, and the table for the last
--	two correspond to the last character.

--	A : First data chracter
--	B : Second data character
--	C : Third data character
--	+ : First two Base 64 characters  (1 and 2)
--	# : Middle two Base 64 characters (2 and 3)
--	% : Last two Base 64 characters   (3 and 4)

--		Another illustration of bit overlaps:
--	AAAAAAAA
--	++++++++++++
--	        BBBBBBBB
--            ############
--                      CCCCCCCC
--                  %%%%%%%%%%%%


--Names:
--	A: Byte 1
--	B: Byte 2
--	C: Byte 3

--	A64: Base64 1
--	B64: Base64 2
--	C64: Base64 3
--	D64: Base64 4

--	ABC: 24 bit value
--	Seq: String sequence
--	B64A: Base 64 alphabet





--Transfer Alphabet string into lookup table
local B64A = {}

for Character = 0, 63 do
	B64A[Character] = Alphabet:sub(Character + 1, Character + 1)
end

--Bit extraction function
local function extract(int, start, endb)
	--convert to 0 based
	start = start - 1

	--convert to correct args
	local width = endb - start
	local field = 24 - start - width --assume 24 bit integer

	--very simple, right shift then mod
	return math.floor(int / 2^field) % 2^width
end


--Generate encoding tables


local EncodeF = {}
local EncodeL = {}
--Encoding table for Data 12 to Base64 12
for A = 0, 255 do
	for B = 0, 255 do
		local Seq = string.char(A, B)
		local ABC = (A * 2^16) + (B * 2^8) + (0 * 2^0)

		local A64 = B64A[ extract(ABC, 1,  6) ]
		local B64 = B64A[ extract(ABC, 7, 12) ]

		EncodeF[Seq] = A64 .. B64
	end

	--Padding for one character segments
	local Seq = string.char(A)
	local ABC = (A * 2^16) + (0 * 2^8) + (0 * 2^0)

	local A64 = B64A[ extract(ABC, 1,  6) ]
	local B64 = B64A[ extract(ABC, 7, 12) ]

	EncodeF[Seq] = A64 .. B64 --Equal signs will be added with EncodeL
end

--Encoding table for Data 23 to Base64 34
EncodeL[""] = Pad .. Pad --(true) Padding for one character segments

for B = 0, 255 do
	for C = 0, 255 do
		local Seq = string.char(B, C)
		local ABC = (0 * 2^16) + (B * 2^8) + (C * 2^0)

		local C64 = B64A[ extract(ABC, 13, 18) ]
		local D64 = B64A[ extract(ABC, 19, 24) ]

		EncodeL[Seq] = C64 .. D64
	end

	--Padding for two character segments
	local Seq = string.char(B)
	local ABC = (0 * 2^16) + (B * 2^8) + (0 * 2^0)

	local C64 = B64A[ extract(ABC, 13, 18) ]
	EncodeL[Seq] = C64 .. Pad
end

--Generate decoding table
local DecodeF = {}
local DecodeM = {}
local DecodeL = {}

--Encoding table for Base64 12 to Data 1
for A64 = 0, 63 do
	for B64 = 0, 63 do
		local Seq = B64A[ A64 ] .. B64A[ B64 ]
		local ABC = (A64 * 2^18) + (B64 * 2^12) + (0 * 2^6) + (0 * 2^0)

		local A = extract(ABC, 1, 8)

		DecodeF[Seq] = string.char( A )
	end
end

--Encoding table for Base64 23 to Data 2
for B64 = 0, 63 do
	for C64 = 0, 63 do
		local Seq = B64A[ B64 ] .. B64A[ C64 ]
		local ABC = (0 * 2^18) + (B64 * 2^12) + (C64 * 2^6) + (0 * 2^0)

		local B = extract(ABC, 9, 16)

		DecodeM[Seq] = string.char( B )
	end

	--Padding for one character segments
	local Seq = B64A[ B64 ] .. Pad
	DecodeM[Seq] = ""
end

--Encoding table for Base64 34 to Data 3
--Padding for one character segments
DecodeM[Pad .. Pad] = ""

for C64 = 0, 63 do
	for D64 = 0, 63 do
		local Seq = B64A[ C64 ] .. B64A[ D64 ]
		local ABC = (0 * 2^18) + (0 * 2^12) + (C64 * 2^6) + (D64 * 2^0)

		local C = extract(ABC, 17, 24)

		DecodeL[Seq] = string.char( C )
	end

	--Padding for two character segments
	local Seq = B64A[ C64 ] .. Pad
	DecodeM[Seq] = ""
end

--[=[
	The parent of all classes.

	@class Base64
]=]
local Base64 = { }


--Encode function

--[=[
	Encodes data into Base64.

	@param Data any -- The data to encode
]=]
function Base64.Encode(Data)
	local Output = {}

	local outp = 1 --Current output index
	for position = 2, #Data + 1, 3 do --Align to middle character
		Output[outp    ] = EncodeF[Data:sub(position - 1, position)]
		Output[outp + 1] = EncodeL[Data:sub(position, position + 1)]
		outp = outp + 2
	end

	return table.concat(Output)
end



--Decode function

--[=[
	Decodes data out of Base64.

	@param Data any -- The data to decode
]=]
function Base64.Decode(Data)
	local Output = {}

	local outp = 1 --Current output index
	for position = 2, #Data + 1, 4 do --Align to second character
		Output[outp    ] = DecodeF[Data:sub(position - 1, position    )]
		Output[outp + 1] = DecodeM[Data:sub(position    , position + 1)]
		Output[outp + 2] = DecodeL[Data:sub(position + 1, position + 2)]
		outp = outp + 3
	end

	return table.concat(Output)
end

Base64.decode = Base64.Decode
Base64.encode = Base64.Encode

return Base64