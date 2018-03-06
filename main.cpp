#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <algorithm>

using namespace std;

//extern "C" void x86_function(char * pixelArray, int width, int height, void* triangle);
extern "C" /*void*/ long x86_function(char * pixelArray, int width, int height, int rsize, void* triangle);
typedef struct
{
	unsigned int A_x;
	unsigned int A_y;
	char A_B;
	char A_G;
	char A_R;
	unsigned int B_x;
	unsigned int B_y;
	char B_B;
	char B_G;
	char B_R;
	unsigned int C_x;
	unsigned int C_y;
	char C_B;
	char C_G;
	char C_R;
} Triangle;

void inputTriangle(Triangle* tr) {
	int table_x[3], table_y[3];
	for (int i = 0; i < 3; ++i) {
		cout << "Wprowadz wspolrzedne wierzcholka\n X: ";
		cin >> table_x[i];
		cout << " Y: ";
		cin >> table_y[i];
	}

	int temp;
	for (int i = 0; i < 3; ++i) {
		for (int j = 0; j < 3; ++j) {
			if (table_y[i] > table_y[j]) {
				temp = table_x[i];
				table_x[i] = table_x[j];
				table_x[j] = temp;

				temp = table_y[i];
				table_y[i] = table_y[j];
				table_y[j] = temp;
			}
		}
	}
	int x_inter;
	x_inter = ((table_x[2] - table_x[0]) *(table_y[1] - table_y[0]) / (table_y[2] - table_y[0])) + table_x[0];
	if (table_x[1] > x_inter) {
		swap(table_x[1], table_x[2]);
		swap(table_y[1], table_y[2]);

	}

	tr->A_x = table_x[0];
	tr->A_y = table_y[0];
	tr->A_R = 0x00;
	tr->A_G = 0xff;
	tr->A_B = 0x00;

	tr->B_x = table_x[1];
	tr->B_y = table_y[1];
	tr->B_R = 0x00;
	tr->B_G = 0x00;
	tr->B_B = 0xff;

	tr->C_x = table_x[2];
	tr->C_y = table_y[2];
	tr->C_R = 0xff;
	tr->C_G = 0x00;
	tr->C_B = 0x00;
}

int main(int argc, char* argv[]) {

	
	fstream file;
	file.open("bg.bmp", ios::in | ios::binary);

	if (file.good() == false) {
	cout << "Blad przy otwieraniu pliku." << endl;
	return 0;
	}
	char *headerBuffer;
	headerBuffer = new char[154];
	int fileSize,offset, arrayWidth, arrayHeight, arraySize;
	file.seekg(+2, ios_base::beg);

	file.read((char*)&fileSize, 4 );

	file.seekg(+10, ios_base::beg);

	file.read((char*)&offset, 4);

	file.seekg(+18, ios_base::beg);

	file.read((char*)&arrayWidth, 4);
	file.read((char*)&arrayHeight, 4);

	file.seekg(+8, ios_base::cur);

	file.read((char*)&arraySize, 4);

	file.seekg(0, ios_base::beg);

	file.read(headerBuffer, offset);

	char* pixelArray = new char[arraySize];

	file.read(pixelArray, arraySize);

	file.close();
	Triangle tr;
	//test(&tr);
	inputTriangle(&tr);

	int rowSize = ((24 * arrayWidth + 31) >> 5) << 2;

	x86_function(pixelArray, arrayWidth, arrayHeight, rowSize, &tr);

	file.open("output.bmp", ios::out | ios::binary | ios::trunc);

	if (file.good() == false) {
	cout << "Blad przy otwieraniu pliku." << endl;
	return 0;
	}

	file.write(headerBuffer, offset);

	file.write(pixelArray, arraySize);

	file.close();

	delete[] headerBuffer;
	delete[] pixelArray;
	
	return 0;
}
