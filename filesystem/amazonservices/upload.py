import os
import boto
from boto.s3.key import Key

BUCKET_NAME = 'jqian-problem2'
AWS_ACCESS_KEY_ID = 'AKIAIEKOY6AJN35SH6ZQ'
AWS_SECRET_ACCESS_KEY = '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'

# set boto lib debug to critical
bucket_name = BUCKET_NAME
# connect to the bucket
conn = boto.connect_s3(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
bucket = conn.get_bucket(bucket_name)

path, dirs, files = os.walk('example').next()

for f in files:
	key = 'example/'+f
	fn = 'example/'+f
	k = Key(bucket)
	k.key = key
	k.set_contents_from_filename(fn)
# go through each version of the file
#key = 'example/test1'
#fn = './example/test1'
# create a key to keep track of our file in the storage
#k = Key(bucket)
#k.key = key
#k.set_contents_from_filename(fn)

# we need to make it public so it can be accessed publicly
# using a URL like http://s3.amazonaws.com/bucket_name/key
k.make_public()
