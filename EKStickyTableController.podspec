Pod::Spec.new do |s|

  s.name         = "EKStickyTableController"
  s.version      = "0.0.6"
  s.summary      = "iOS UITableView drag to expand/collapse header behaviour like Foursquare TableView + Map"

  s.description  = <<-DESC
                  A UITableViewDelegate that holds all required code to drag to expand and scroll to collapse listView
                  with a transparent header that allows events passing through it and reach the container below (i.e. MKMapView), on YesWePlay application we required to mimic the Foursquare listview+map behavior so this is the controller that allows us to do it.

                   DESC

  s.homepage     = "https://github.com/elikohen/EKStickyTableController"

  s.license      = 'MIT'

  s.author             = { "Eli Kohen" => "elikohen@gmail.com" }
  
  s.platform     = :ios, '6.0'

  s.source       = { :git => "https://github.com/elikohen/EKStickyTableController.git", :tag => "0.0.6" }

  s.source_files  = 'EKStickyTableController/*.{h,m}'
  s.exclude_files = 'StickyTableControllerSample'

  s.public_header_files = 'EKStickyTableController/EKStickyTableController.h'

  s.requires_arc = true

end
