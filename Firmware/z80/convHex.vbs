Option Explicit

Dim objTextStream
dim objFso
Dim strLines
dim file_name
dim rec_len, rec_adr, rec_type, rec_data
dim i, byte_data
dim hex_data
dim rlen_H, rlen_L

' �t�@�C�����̎��o��
file_name = WScript.Arguments.Item(0)

Set objFso = CreateObject("Scripting.FileSystemObject")

If objFso.FileExists(file_name) = false Then
    WScript.Echo "�t�@�C�������݂��܂���B"

	Set objFso = Nothing

	WScript.Quit
End If

'�e�L�X�g�t�@�C�����J���ATextStream�I�u�W�F�N�g�̎擾
Set objTextStream = objFSO.OpenTextFile(file_name)

hex_data = ""

'TextStream���Ō���̈ʒu�ɂȂ�܂ŌJ��Ԃ�
Do Until objTextStream.AtEndOfStream

	'��s��ǂݍ��ݕ�����ϐ��ɒǋL����
	strLines = objTextStream.ReadLine()

'debug
'WScript.Echo objTextStream.AtEndOfStream
'WScript.Echo strLines

	if left(strLines, 1) = ":" then 	'�����̐擪��":"�����ׂ�
		
'		rec_len : �f�[�^�̒���
		rlen_H = asc(mid(strLines, 2,1)) - asc("0")
		rlen_L = asc(mid(strLines, 3,1)) - asc("0")

		if rlen_H > 9 then rlen_H = (rlen_H and &h0f) + 9
		if rlen_L > 9 then rlen_L = (rlen_L and &h0f) + 9
		rec_len = rlen_H *16 + rlen_L

		rec_adr = mid(strLines, 4,4)	'���R�[�h�̃��P�[�V�����A�h���X
		rec_type = mid(strLines, 8,2)	'���R�[�h�^�C�v

		if rec_type = "00" then

			rec_data = mid(strLines, 10, rec_len*2)	'���R�[�h�̃f�[�^
			byte_data = ""

			for i = 0 to rec_len - 1
				byte_data = byte_data & "0x" & mid(rec_data, i*2+1, 2) & ","
			next
			hex_data = hex_data & byte_data & vbCrLf

'debug
'WScript.Echo hex_data
'WScript.Quit

		end if
	end if

Loop

WScript.Echo left(hex_data, len(hex_data)-3)
'WScript.Echo vbCrLf

objTextStream.Close() 'TextStream�����

Set objFSO = Nothing
Set objTextStream = Nothing
