#!/bin/bash
# do not run this script, exec these commands in rials console

user = User.find_by(email: 'yongjinapple@aliyun.com')
user.admin?
user.toggle!(:admin)
user.admin?
