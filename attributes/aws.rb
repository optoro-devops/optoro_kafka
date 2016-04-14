
# EXT4 log devices
if node['ec2']
  default['optoro_kafka']['log']['devices'] = {
    '/dev/xvdf' => {
      'file_system' => 'ext4',
      'mount_options' => 'rw,user',
      'mount_path' => '/kafka/disk1',
      'format_command' => 'mkfs.ext4',
      'fs_check_command' => 'dumpe2fs',
      'ebs' => {
        'device' => '/dev/sdf',
        'size' => 250,
        'delete_on_termination' => true,
        'type' => 'standard'
      }
    },
    '/dev/xvdg' => {
      'file_system' => 'ext4',
      'mount_options' => 'rw,user',
      'mount_path' => '/kafka/disk2',
      'format_command' => 'mkfs.ext4',
      'fs_check_command' => 'dumpe2fs',
      'ebs' => {
        'device' => '/dev/sdg',
        'size' => 250,
        'delete_on_termination' => true,
        'type' => 'standard'
      }
    },
    '/dev/xvdh' => {
      'file_system' => 'ext4',
      'mount_options' => 'rw,user',
      'mount_path' => '/kafka/disk3',
      'format_command' => 'mkfs.ext4',
      'fs_check_command' => 'dumpe2fs',
      'ebs' => {
        'device' => '/dev/sdh',
        'size' => 250,
        'delete_on_termination' => true,
        'type' => 'standard'
      }
    },
    '/dev/xvdi' => {
      'file_system' => 'ext4',
      'mount_options' => 'rw,user',
      'mount_path' => '/kafka/disk4',
      'format_command' => 'mkfs.ext4',
      'fs_check_command' => 'dumpe2fs',
      'ebs' => {
        'device' => '/dev/sdi',
        'size' => 250,
        'delete_on_termination' => true,
        'type' => 'standard'
      }
    }
  }
else
  default['optoro_kafka']['log']['devices'] = {}
end
