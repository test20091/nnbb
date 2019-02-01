#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <grp.h>
#include <pwd.h>
#include <unistd.h>
#include <dirent.h>
#include <string.h>
#include <sys/acl.h>
#include <sys/xattr.h>
#include "ls.h"
#include "libft/includes/libft.h"
# define R 1
# define l 2
# define a 4
# define r 8
# define t 16
# define S 32


t_argv	*listall(int argc, char **argv, t_argv *list, int i)
{
	int		checkargs;
	t_argv	*tmp;
	struct	stat sf;
	char	*tmp1;
	checkargs = 0;
	list = (t_argv*)malloc(sizeof(t_argv));
	list->prev = (t_argv*)malloc(sizeof(t_argv));
	list->prev->agname = NULL;
	tmp = list;
	list->agname = ft_strdup(".");
	while (i < argc && argv[i])
	{
		checkargs = 1;
		tmp1 = (list->agname);
		list->agname = ft_strdup(argv[i]);
		list->name = ft_strdup(argv[i]);
		if (stat(list->agname, &sf) != -1)
		free(tmp1);
		list->next = (t_argv*)malloc(sizeof(t_argv));
		list->next->prev = (t_argv*)malloc(sizeof(t_argv));
		list->next->prev = list;
		list->mtime = sf.st_mtime;
		list->size = sf.st_size;
		list->next->agname = NULL;
		list = list->next;
		list->next = NULL;
		i++;
	}
	return (tmp);
}

int	parseargs(int argc, char **argv, int *flag)
{
	int i;
	int j;
	i = 1;
	while (i < argc)
	{
		j = 0;
		while (argv[i][j])
		{
			if (argv[i][0] == '-' && argv[i][1] == '-' && strlen(argv[i]) == 2)
				return (++i);
			if (argv[i][0] != '-')
				return (i);
			if (!strchr("ABCFGHLOPRSTUWabcdefghiklmnopqrstuwx1",argv[i][j]) && j > 0)
			{
				printf("ls: illegal option -- %c\nusage: ls [-ABCFGHLOPRSTUWabcdefghiklmnopqrstuwx1] [file ...]", argv[i][j]);
				*argv = 0;
				return(-1);
			}
			if (argv[i][j] == 'l')
				(*flag & l) == 0 ? *flag += l : 0;	
			if (argv[i][j] == 'R')
				(*flag & R) == 0 ? *flag += R : 0;
			if (argv[i][j] == 'a')
				(*flag & a) == 0 ? *flag += a : 0;
			if (argv[i][j] == 'r')
				(*flag & r) == 0 ? *flag += r : 0;
			if (argv[i][j] == 't')
				(*flag & t) == 0 ? *flag += t : 0;
			if (argv[i][j] == 'S')
				(*flag & S) == 0 ? *flag += S : 0;
			j++;
		}
		i++;
	}
	return(i);
}
void		print_file_type(int mode)
{
	mode = (mode & S_IFMT);
	if (S_ISREG(mode))
		ft_putchar ('-');
	else if (S_ISDIR(mode))
		ft_putchar ('d');
	else if (S_ISLNK(mode))
		ft_putchar ('l');
	else if (S_ISBLK(mode))
		ft_putchar ('b');
	else if (S_ISCHR(mode))
		ft_putchar ('c');
	else if (S_ISSOCK(mode))
		ft_putchar ('s');
	else if (S_ISFIFO(mode))
		ft_putchar ('p');
	else
		ft_putchar ('-');
}
void	printpermissions(struct stat sb, char *path)
{
	int x1;
	int x2;
	int x3;
	char buffer[256];
	acl_t	acl;
	x1 = (sb.st_mode & S_IXUSR) ? 'x' : '-';
	x2 = (sb.st_mode & S_IXGRP) ? 'x' : '-';
	x3 = (sb.st_mode & S_IXOTH) ? 'x' : '-';
	if (S_ISUID & sb.st_mode)
		x1 = x1 == '-' ? 'S' : 's';
	if (S_ISGID & sb.st_mode)
		x2 = x2 == '-' ? 'S' : 's';
	if (S_ISVTX & sb.st_mode)
		x3 = x3 == '-' ? 'T' : 't';
	print_file_type(sb.st_mode);
    printf( (sb.st_mode & S_IRUSR) ? "r" : "-");
    printf( (sb.st_mode & S_IWUSR) ? "w" : "-");
    printf("%c",x1);
    printf( (sb.st_mode & S_IRGRP) ? "r" : "-");
    printf( (sb.st_mode & S_IWGRP) ? "w" : "-");
    printf("%c",x2);
    printf( (sb.st_mode & S_IROTH) ? "r" : "-");
    printf( (sb.st_mode & S_IWOTH) ? "w" : "-");
    printf("%c",x3);
	if (listxattr(path, NULL, 0, XATTR_NOFOLLOW) > 0)
	{
		putchar('@');
		return;
	}
	if ((acl = acl_get_link_np(path, ACL_TYPE_EXTENDED)))
	{
		acl_free(acl);
		putchar('+');
		return;
	}
	putchar(' ');
}
int	isdir(struct stat sb)
{
	if (S_ISDIR(sb.st_mode))
		return (1);
	return (0);
}

void	ft_swap(char **s1, char **s2)
{
	char *tmp;

	tmp = *s1;
	*s1 = *s2;
	*s2 = tmp;
}
void	ft_swaptime(long *t1, long *t2)
{
	long tmp;

	tmp = *t1;
	*t1 = *t2;
	*t2 = tmp;
}
t_argv *sort_list(t_argv *list)
{
	t_argv *head;
	head = list;
	int swaped;
	swaped = 0;
	while(list->next->agname != 0)
	{
		if (strcmp(list->name,list->next->name) > 0)
		{
			ft_swap(&(list->agname), &(list->next->agname));
			ft_swap(&(list->name), &(list->next->name));
			swaped = 1;
		}
		list = list->next;
		if (list->next->agname == 0 && swaped)
		{
			list = head;
			swaped = 0;
		}
	}
	return(head);
}
t_argv *tsort_list(t_argv *list)
{
	t_argv *head;
	head = list;
	int swaped;
	swaped = 0;
	while(list->next->agname != 0)
	{
		if (list->mtime < list->next->mtime)
		{
			ft_swap(&(list->agname), &(list->next->agname));
			ft_swap(&(list->name), &(list->next->name));
			ft_swaptime(&(list->mtime), &(list->next->mtime));
			swaped = 1;
		}
		list = list->next;
		if (list->next->agname == 0 && swaped)
		{
			list = head;
			swaped = 0;
		}
	}
	return(head);
}
t_argv *sizesort_list(t_argv *list)
{
	t_argv *head;
	head = list;
	int swaped;
	swaped = 0;
	while(list->next->agname != 0)
	{
		if (list->size < list->next->size)
		{
			ft_swap(&(list->agname), &(list->next->agname));
			ft_swap(&(list->name), &(list->next->name));
			ft_swaptime(&(list->mtime), &(list->next->mtime));
			ft_swaptime(&(list->size), &(list->next->size));
			swaped = 1;
		}
		list = list->next;
		if (list->next->agname == 0 && swaped)
		{
			list = head;
			swaped = 0;
		}
	}
	return(head);
}
t_argv *rsort_list(t_argv *list)
{
	t_argv *head;
	while(list->next->agname != 0)
		list = list->next;
	head = list;
	while (list)
	{
		list->next = list->prev;
		list = list->next;
	}
	list = malloc(sizeof(t_argv));
	//list->agname = NULL;
	return(head);
}
t_argv *rrsort_list(t_argv *list)
{
	t_argv *head;
	head = list;
	while(list->next->agname != 0)
		list = list->next;
	while(list->prev)
	{
		printf("%s\n", list->name);
		list = list->prev;
	}
	return(head);
}

void	fetchdir(char *agname, int flag, int count, int first)
{
	char	lnk[1024];
	struct	group *grp;
	struct	passwd *pwd;
	char	**mtime;
	struct	stat sf;
	char	*test;
	struct	dirent *dent;
	int		block = 0;
	DIR		*dir;
	!first ? putchar('\n') : 0;
	count > 0 ? printf("%s:\n",agname) : 0;
	if (!(dir = opendir(agname)))
	{
		test = ft_strjoin("ls: ",strrchr(agname,'/')+1);
		perror(test);
		return;
	}
	t_argv *tmp;
	t_argv *list = (t_argv*)malloc(sizeof(t_argv));
	list->prev = (t_argv*)malloc(sizeof(t_argv));
	list->prev->agname = NULL;
	tmp = list;
	if(dir != NULL)
	{
		while((dent=readdir(dir))!=NULL)
		{
			char *fpath;
			char *ftmp;
			fpath = ft_strjoin(agname,"/");
			ftmp= fpath;
			fpath = ft_strjoin(fpath,dent->d_name);
			free(ftmp);
			ftmp = list->agname;
			list->agname = ft_strdup(fpath);
			list->name = ft_strdup(dent->d_name);
			if (lstat(fpath, &sf) != -1)
				 block += sf.st_blocks;
			list->mtime = sf.st_mtime;
			list->size = sf.st_size;
			list->next = (t_argv*)malloc(sizeof(t_argv));
			list->next->prev = list;
			list->next->agname = NULL;
			list = list->next;
			free(fpath);
		}
		closedir(dir);
		list = tmp;
		tmp = flag & S ? sizesort_list(list) : tmp;
		tmp = (flag & t) && !(flag & S) ? tsort_list(list) : tmp;
		if (!(flag & r) && !(flag & t) && !(flag & S))
			tmp = sort_list(list);
		tmp = flag & r ? rsort_list(list) : tmp;
		list = tmp;
		flag & l ? printf("total %d\n",block) : 0;
		while(list->agname != NULL)
		{
			if (!(flag & a) && (strrchr(list->agname,'/')+1)[0] == '.')
			{
				list = list->next;
				continue;
			}
			if (lstat(list->agname, &sf) != -1)
			{
				!isdir(sf) ? block += sf.st_blocks : 0;
				if (!(flag & l))
				{
					printf("%s\n", strrchr(list->agname,'/')+1);
					list = list->next;
					continue;
				}
				printpermissions(sf,list->agname);
				pwd = getpwuid(sf.st_uid);
				printf("% 3ld ", (long) sf.st_nlink);
				printf("%s", pwd->pw_name);
				grp = getgrgid(sf.st_gid);
				printf("  %s ",grp->gr_name);
				if (sf.st_size)
				printf(" % 6lld ",(long long) sf.st_size);
				else
				{
					if (!S_ISLNK(sf.st_mode))
						printf(" % 3d,",major(sf.st_rdev));
					else 
						printf("   ");
					printf(" % 3d ",minor(sf.st_rdev));
				}
				mtime = ft_strsplit(ctime(&sf.st_ctime),' ');
				printf("%s %s %s:%s",mtime[1],mtime[2],ft_strsplit(mtime[3],':')[0],ft_strsplit(mtime[3],':')[1]);
				if (S_ISLNK(sf.st_mode))
				{
					printf(" \033[0;35m%s\033[0m",strrchr(list->agname,'/')+1);
					ssize_t len;
					len = readlink(list->agname, lnk, sizeof(lnk)-1);
					lnk[len] = '\0';
					printf(" -> %s\n", lnk);
				}
				else
				{
					printf(" %s\n", strrchr(list->agname,'/')+1);
				}
			}
			list = list->next;
		}
		list = tmp;
		while(list->agname != NULL)
		{
			if (lstat(list->agname, &sf) != -1)
			{
				if (isdir(sf) && !S_ISLNK(sf.st_mode) && flag & R)
				{
					if (!ft_strequ(strrchr(list->agname,'/')+1, ".") && !ft_strequ(strrchr(list->agname,'/')+1, "..") )
					{
						if (!(flag & a) && (strrchr(list->agname,'/')+1)[0] == '.')
						{
							list = list->next;
							continue;
						}
						fetchdir(list->agname, flag, 1, 0);
					}
				}
			}
			list = list->next;
		}
		list = tmp;
		while(list->agname != NULL)
		{
			t_argv *tmp;
			tmp = list;
			free(list->agname);
			free(list->name);
			list = list->next;
			free(tmp);
		}
		free(list->agname);
		free(list);

	}
	else
	{
		free(list);
		return ;
	}
	
}
int linktodir(struct stat sb, char *file)
{
	char lnk[1024];
	struct stat sf;
	if (S_ISLNK(sb.st_mode))
	{
		ssize_t len;
		len = readlink(file, lnk, sizeof(lnk)-1);
		lnk[len] = '\0';
		lstat(lnk, &sf);
		if (S_ISDIR(sf.st_mode))
			return(1);
	}
	return (0);
}
int main(int argc, char **argv)
{
	int flag = 0;
	int retflag;
	t_argv *list;
	t_argv *tmp;
	t_argv *head;
	t_argv *sorted;
	struct stat sb;
    struct group *grp;
	struct passwd *pwd;
	char **mtime;
	int first = 1;
	retflag = parseargs(argc, argv, &flag);
	if (retflag == -1)
	{
		putchar('\n');
		return(1);
	}
	tmp = listall(argc, argv, list, retflag);
	head = tmp;

	sorted = flag & S ? sizesort_list(head) : head; ;
	sorted = (flag & t) && !(flag & S) ? tsort_list(head) : head;
	if (!(flag & r) && !(flag & t) && !(flag & S))
		sorted = sort_list(head);
	sorted = flag & r ? rsort_list(sorted) : sorted;

	tmp = head;
	tmp = sorted;
	head = sorted;
	int count = 0;
	while (tmp->next)
	{
		count++;
		if (stat(tmp->agname, &sb) == -1)
		{
			char *test;
			test = ft_strjoin("ls: ",tmp->agname);
			perror(test);
		}
		tmp = tmp->next;
	}
	tmp = head;
	while (tmp->next)
	{
		if (lstat(tmp->agname, &sb) != -1 &&   !isdir(sb) )
		{
			if (linktodir(sb,tmp->agname) && !(flag & l))
			{
				tmp = tmp->next;
				first = 0;
				continue;
			}
			if (!(flag & l))
			{
				printf("%s\n", tmp->agname);
				first = 0;
				tmp = tmp->next;
				continue;
			}
			char lnk[1024];
			printpermissions(sb,tmp->agname);
			pwd = getpwuid(sb.st_uid);
			printf(" %ld ", (long) sb.st_nlink);
			printf(" %s", pwd->pw_name);
			grp = getgrgid(sb.st_gid);
			printf(" %s ",grp->gr_name);
			if (sb.st_size)
				printf(" % 6lld ",(long long) sb.st_size);
			else
			{
				printf(" % 6d   ",minor(sb.st_rdev));
				printf(" % 6d ",major(sb.st_rdev));
			}
			mtime = ft_strsplit(ctime(&sb.st_mtime),' ');
			printf("%s %s %s:%s",mtime[1],mtime[2],ft_strsplit(mtime[3],':')[0],ft_strsplit(mtime[3],':')[1]);
			first = 0;
			if (S_ISLNK(sb.st_mode))
			{
				printf(" \033[0;35m%s\033[0m",tmp->agname);
				ssize_t len;
				len = readlink(tmp->agname, lnk, sizeof(lnk)-1);
				lnk[len] = '\0';
				printf(" -> %s\n", lnk);
			}
			else
			{
				printf(" %s\n", tmp->agname);
			}
		}
		tmp = tmp->next;
	}
	tmp = head;
	while (tmp->next)
	{
		if (lstat(tmp->agname, &sb) != -1 && (isdir(sb) || (linktodir(sb,tmp->agname) && !(flag & l))))
			fetchdir(tmp->agname, flag, count-1, first);
		tmp = tmp->next;
	}
	tmp = head;
	while(head->agname != NULL)
	{
		t_argv *tmp;
		tmp = head;
		free(head->agname);
		free(head->name);
		head = head->next;
		free(tmp);
	}
	free(head->agname);
	free(head);
	return (0);
}
