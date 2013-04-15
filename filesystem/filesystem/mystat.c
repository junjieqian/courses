#include <sys/stat.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <time.h>
#include <grp.h>
#include <pwd.h>

int main (int argc, char* argv[])
{
	struct stat fileattributes;
	if(argc !=2 ){
		printf("Usage: ./mystat <file or path name> \n");
		return 1;
	}

	if(stat(argv[1], &fileattributes) < 0){
		printf("Wrong filename. \n");
		return 1;
	}

	struct group *grp;
	struct passwd *pwd;
	pwd = getpwuid(fileattributes.st_uid);
	grp = getgrgid(fileattributes.st_gid);

	printf("Information for file:  %s \n", argv[1]);
	printf("------------------------------------------\n");
	printf("Size: %lld bytes \t", (long long)fileattributes.st_size);
	printf("Blocks: %lld \t", (long long)fileattributes.st_blocks);
	printf("IO Block: %ld  directory\n", (long)fileattributes.st_blksize);
	printf("Device: %ldh/%jud \t", (long)fileattributes.st_dev, (uintmax_t)fileattributes.st_dev);
	printf("Inode: %ld \t", (long)fileattributes.st_ino);
	printf("Links: %ld \n", (long)fileattributes.st_nlink);
	
//	printf("Access: %lo ", (unsigned long)fileattributes.st_mode);
	printf("Access: %04o ", fileattributes.st_mode & 07777);
	printf( (S_ISDIR(fileattributes.st_mode)) ? "d" : "-");
	printf( (fileattributes.st_mode & S_IRUSR) ? "r" : "-");
	printf( (fileattributes.st_mode & S_IWUSR) ? "w" : "-");
	printf( (fileattributes.st_mode & S_IXUSR) ? "x" : "-");
	printf( (fileattributes.st_mode & S_IRGRP) ? "r" : "-");
	printf( (fileattributes.st_mode & S_IWGRP) ? "w" : "-");
	printf( (fileattributes.st_mode & S_IXGRP) ? "x" : "-");
	printf( (fileattributes.st_mode & S_IROTH) ? "r" : "-");
	printf( (fileattributes.st_mode & S_IWOTH) ? "w" : "-");
	printf( (fileattributes.st_mode & S_IXOTH) ? "x" : "-");
	printf("\t");
	
	printf("Uid: %ld, %s\t ", (long)fileattributes.st_uid, pwd->pw_name);
	printf("Gid: %ld, %s \n", (long)fileattributes.st_gid, grp->gr_name);
	printf("Access: %s", ctime(&fileattributes.st_atime));
	printf("Modify: %s", ctime(&fileattributes.st_mtime));
	printf("Change: %s", ctime(&fileattributes.st_ctime));

	return 0;
}
