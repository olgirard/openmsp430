#include <stdarg.h>

#include "cprintf.h"

typedef unsigned char byte;

static char hex[] = "0123456789abcdef";

void
cput_nibble (int n)
{
  tty_putc (hex[n&0x0f]);
}

void
cput_hex_byte (int n)
{
  cput_nibble (n >> 4);
  cput_nibble (n);
}

void
cput_binary_byte (int n)
{
  int i;
  for (i=7; i>=0; i--)
    tty_putc((n & (1<<i)) ? '1' : '0');
}

void
cput_hex_word (int n)
{
  cput_hex_byte (n >> 8);
  cput_hex_byte (n);
}

void
cput_hex_long (long int n)
{
  cput_hex_byte (n >> 24);
  cput_hex_byte (n >> 16);
  cput_hex_byte (n >> 8);
  cput_hex_byte (n);
}

void
cput_hex_block (char *block, int n)
{
  int i = 0;
  while (n)
    {
      cput_hex_byte (*block++);
      if (--n == 0)
	break;
      i++;
      if ((i & 7) == 0)
	tty_putc (' ');
      else
	tty_putc (':');
    }
}

void
cput_nibble_block (char *block, int n)
{
  int i = 0;
  while (n)
    {
      cput_nibble (*block);
      if (--n == 0)
	break;
      i++;
      if ((i & 7) == 0)
	tty_putc (' ');
    }
}

void
cput_number (int n)
{
  char buf[20];
  int i = 0;
  if (n < 0)
    {
      tty_putc ('-');
      n = -n;
    }
  while (n > 9)
    {
      buf[i++] = (n%10) + '0';
      n /= 10;
    }
  buf[i++] = (n%10) + '0';
  while (i > 0)
    tty_putc (buf[--i]);
}

void
cprintf (const char *fmt, ...)
{
  va_list v;
  int i;
  char *s;

  va_start (v, fmt);

  while (*fmt)
    {
      if (*fmt != '%')
	tty_putc (*fmt);
      else
	switch (*++fmt)
	  {
	  case '%':
	    tty_putc ('%');
	    break;
	  case 'c':
	    i = va_arg (v, int);
	    tty_putc(i);
	    break;
	  case 'd':
	    i = va_arg (v, int);
	    cput_number(i);
	    break;
	  case 'b':
	    i = va_arg (v, int);
	    cput_hex_byte (i);
	    break;
	  case 'B':
	    i = va_arg (v, int);
	    cput_binary_byte (i);
	    break;
	  case 'w':
	    i = va_arg (v, int);
	    cput_hex_word (i);
	    break;
	  case 'l':
	    i = va_arg (v, int);
	    cput_hex_long (i);
	    break;
	  case 'x':
	    s = va_arg (v, char *);
	    i = va_arg (v, int);
	    cput_hex_block (s, i);
	    break;
	  case 'n':
	    s = va_arg (v, char *);
	    i = va_arg (v, int);
	    cput_nibble_block (s, i);
	    break;
	  case 's':
	    s = va_arg (v, char *);
	    tty_putc (s);
	    break;
	  }
      fmt ++;
    }
}
