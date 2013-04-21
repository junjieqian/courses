from boto.s3.connection import S3Connection

conn = S3Connection('AKIAIEKOY6AJN35SH6ZQ','XDbtFOawG2eOz+yf/fSEkx49gzZ3AsxEJKzR6p8v')

for bucket in conn.get_all_buckets():
	print "{name}\t{created}".format(name = bucket.name, created = bucket.creation_date,)
	buc = conn.get_bucket(bucket.name)
	for key in bucket.list():
		print key.name.encode('utf-8')

#bucket = conn.get_bucket('jqian-problem2')
#for key in bucket.list():
#    print key.name.encode('utf-8')
