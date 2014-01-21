#include<iostream>
#include<string>
#include<cstring>
#include<cstdio>
using namespace std;

/*
	ldi r16, SOUND_h1
	ldi r17, QUARTER_NOTE
	rcall play_sound	
	*/
	
char input[10000];
string H[1000],L[1000];

int main() {
	H['c'] = "SOUND_c1";	
	H['d'] = "SOUND_d1";
	H['e'] = "SOUND_e1";
	H['f'] = "SOUND_f1";
	H['g'] = "SOUND_g1";
	H['a'] = "SOUND_a1";
	H['h'] = "SOUND_h1";
	H['C'] = "SOUND_c2";	
	H['D'] = "SOUND_d2";
	H['E'] = "SOUND_e2";
	H['F'] = "SOUND_f2";
	H['G'] = "SOUND_g2";
	H['A'] = "SOUND_a2";
	H['H'] = "SOUND_h2";
	
	L[10] = "WHOLE_NOTE";
	L[11] = "WHOLE_NOTE + HALF_NOTE";
	L[20] = "HALF_NOTE";
	L[21] = "HALF_NOTE + QUARTER_NOTE";
	L[40] = "QUARTER_NOTE";
	L[41] = "QUARTER_NOTE + EIGHTH_NOTE";
	L[80] = "EIGHTH_NOTE";
	L[81] = "EIGHTH_NOTE + SIXTH_NOTE";
	L[90] = "SIXTH_NOTE";
	input[0] = 'a';
	while(input[0]!='#') {
		scanf("%s", input);
		if(input[0] == '#') break;
		int n = strlen(input);
		for(int i = 0; i < n; i += 3) {
			if(input[i] == '0') {
				cout << "ldi r16, " << L[(input[i+1] - '0')*10 + (input[i+2] - '0')] << "\n";
				cout << "rcall superlong\n";
				continue;
			}
			cout << "ldi r16, " << H[input[i]] << "\n";
			cout << "ldi r17, " << L[(input[i+1] - '0')*10 + (input[i+2] - '0')] << "\n";
			cout << "rcall play_sound\n";
		}
		cout << "\n";
	}
}