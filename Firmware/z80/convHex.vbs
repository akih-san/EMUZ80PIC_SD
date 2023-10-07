Option Explicit

Dim objTextStream
dim objFso
Dim strLines
dim file_name
dim rec_len, rec_adr, rec_type, rec_data
dim i, byte_data
dim hex_data
dim rlen_H, rlen_L

' ファイル名の取り出し
file_name = WScript.Arguments.Item(0)

Set objFso = CreateObject("Scripting.FileSystemObject")

If objFso.FileExists(file_name) = false Then
    WScript.Echo "ファイルが存在しません。"

	Set objFso = Nothing

	WScript.Quit
End If

'テキストファイルを開き、TextStreamオブジェクトの取得
Set objTextStream = objFSO.OpenTextFile(file_name)

hex_data = ""

'TextStreamが最後尾の位置になるまで繰り返す
Do Until objTextStream.AtEndOfStream

	'一行を読み込み文字列変数に追記する
	strLines = objTextStream.ReadLine()

'debug
'WScript.Echo objTextStream.AtEndOfStream
'WScript.Echo strLines

	if left(strLines, 1) = ":" then 	'文字の先頭が":"か調べる
		
'		rec_len : データの長さ
		rlen_H = asc(mid(strLines, 2,1)) - asc("0")
		rlen_L = asc(mid(strLines, 3,1)) - asc("0")

		if rlen_H > 9 then rlen_H = (rlen_H and &h0f) + 9
		if rlen_L > 9 then rlen_L = (rlen_L and &h0f) + 9
		rec_len = rlen_H *16 + rlen_L

		rec_adr = mid(strLines, 4,4)	'レコードのロケーションアドレス
		rec_type = mid(strLines, 8,2)	'レコードタイプ

		if rec_type = "00" then

			rec_data = mid(strLines, 10, rec_len*2)	'レコードのデータ
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

objTextStream.Close() 'TextStreamを閉じる

Set objFSO = Nothing
Set objTextStream = Nothing
