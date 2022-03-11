import Foundation

struct Container {
    let provider: StorageType = .S3 //CharField(max_length=20, default=StorageType.S3, choices=StorageType.choices(), verbose_name=u'Storage Provider')
    let name: String = "" //CharField(max_length=255, default='', blank=True, help_text=u'Name for the storage container; for example the S3 bucket name')
    let region: String = "" //CharField(max_length=50, default='', blank=True, help_text=u'Region of the bucket for AWS')
    let auto_distill: Bool = true //BooleanField(default=True, help_text=u'Automatically create distill jobs for supported files added to this container')
}
