/*  homework4, myls.c
 *  Junjie Qian, jqian@cse.unl.edu
 *  Refer to the Linux LS.C file
 */

#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <err.h>
#include <fcntl.h>
#include <dirent.h>
#include <grp.h>
#include <pwd.h>

void do_ls(char[]);
void ls_l(char[]);
void dostat(char *);
void show_file_info(char *, struct stat );

int main(int argc, char *argv[])
{
	// lopt to indicate whether there is the option -l
	int lopt = 0;
	int aopt = 0;

	int i,j,k = 0;
	for(i=1; i<argc;i++){
		if (strcmp(argv[i], "-l") == 0)
			lopt = 1;
		// optional for '-a' function, if needed pass the value to next function
		if (strcmp(argv[i], "-a") == 0)
			aopt = 1;
	}

	if (lopt == 1){
		if (argc == 2)
			ls_l(".");
		else 
			while(--argc){
				printf("%s: \n", *++argv);
				ls_l(*argv);
			}
	} 
	else if (argc == 1)
		do_ls(".");
	else
		while(--argc){
			printf("%s: \n", *++argv);
			do_ls(*argv);
		}

	return 0;
}

// list the files and count the file number
void do_ls(char buffer[])
{
	DIR   *dir_ptr;
	struct dirent *direntp;
	int count = 0;

	if ((dir_ptr = opendir(buffer)) == NULL)
		printf("directory doesnot exits!");
	else{
		while((direntp = readdir(dir_ptr)) != NULL){
			if(strcmp(direntp->d_name, ".") == 0 || strcmp(direntp->d_name, "..") == 0)
				continue;
	//		if (direntp->d_type == DT_REG){
				printf("%s\t", direntp->d_name);
				count ++;
	//		}
		}
		closedir(dir_ptr);
		printf("\nTotal file number: %d\n", count);
	}
}

// same function with ls but one more function '-l'
void ls_l(char buffer[])
{
	DIR   *dir_ptr;
	struct dirent *direntp;
	int count = 0;

	if ((dir_ptr = opendir(buffer)) == NULL)
		printf("directory doesnot exits!");
	else{
		while((direntp = readdir(dir_ptr)) != NULL){
			if(strcmp(direntp->d_name, ".") == 0 || strcmp(direntp->d_name, "..") == 0)
				continue;
			dostat(direntp->d_name);
			count ++;
		}
		closedir(dir_ptr);
		printf("\nTotal file number: %d\n", count);
	}
}

// do stat file, check whether it exits, then print out the information
void dostat(char *filename)
{
	struct stat info;

	// if no stat info for this file
	if(stat(filename, &info) < 0)
		perror(filename);
	else
		show_file_info(filename, info);
}

void show_file_info(char *filename, struct stat info)
{
	struct group *grp;
	struct passwd *pwd;
	grp = getgrgid(info.st_gid);
	pwd = getpwuid(info.st_uid);

	printf( (info.st_mode & S_IRUSR) ? "r" : "-");
	printf( (info.st_mode & S_IWUSR) ? "w" : "-");
	printf( (info.st_mode & S_IXUSR) ? "x" : "-");
	printf( (info.st_mode & S_IRGRP) ? "r" : "-");
	printf( (info.st_mode & S_IWGRP) ? "w" : "-");
	printf( (info.st_mode & S_IXGRP) ? "x" : "-");
	printf( (info.st_mode & S_IROTH) ? "r" : "-");
	printf( (info.st_mode & S_IWOTH) ? "w" : "-");
	printf( (info.st_mode & S_IXOTH) ? "x" : "-");

	printf( " %s", pwd->pw_name);
	printf(" %s", grp->gr_name);
	printf(" %s", filename);
	printf(" %s", ctime(&info.st_ctime));
//	printf(" %s\n", filename);
}
