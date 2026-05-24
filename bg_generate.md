# 1. W+jets (semi-leptonic)
```
generate p p > w+ j j, (w+ > l+ vl)
add process p p > w- j j, (w- > l- vl~)
output BG_Wjets
launch BG_Wjets
```

# 2. Z+jets (with lepton pair)
```
generate p p > z j j, (z > l+ l-)
output BG_Zjets
launch BG_Zjets
```

# 3. tt+jets (semi-leptonic: one W→lν, one W→jj)
```
generate p p > t t~ j, (t > b w+, w+ > l+ vl), (t~ > b~ w-, w- > j j)
add process p p > t t~ j, (t > b w+, w+ > j j), (t~ > b~ w-, w- > l- vl~)
output BG_ttjets
launch BG_ttjets
```

# 4. tW (semi-leptonic) - VALID SYNTAX
```
generate g b > t w-, (t > b l+ vl), (w- > j j)
add process g b~ > t~ w+, (t~ > b~ l- vl~), (w+ > j j)
output BG_tW
launch BG_tW
```

# 5. tb (single top + b)
```
generate p p > t b~, (t > b w+, w+ > l+ vl)
add process p p > t~ b, (t~ > b~ w-, w- > l- vl~)
output BG_tb
launch BG_tb
```

# 6. t+jets (single top)
```
generate u b > t d, (t > b w+, w+ > l+ vl)
add process c b > t s, (t > b w+, w+ > l+ vl)
add process d b~ > t~ u, (t~ > b~ w-, w- > l- vl~)
add process s b~ > t~ c, (t~ > b~ w-, w- > l- vl~)
output BG_tjets
launch BG_tjets
```

# 7. WW+jets
```
generate p p > w+ w- j, (w+ > l+ vl), (w- > j j)
add process p p > w+ w- j, (w+ > j j), (w- > l- vl~)
output BG_WWjets
launch BG_WWjets
```

# 8. WZ+jets
```
generate p p > w+ z j, (w+ > l+ vl), (z > j j)
add process p p > w- z j, (w- > l- vl~), (z > j j)
output BG_WZjets
launch BG_WZjets
```

# 9. ttZ
```
generate p p > t t~ z, (t > b w+, w+ > l+ vl), (t~ > b~ w-, w- > j j), (z > j j)
add process p p > t t~ z, (t > b w+, w+ > j j), (t~ > b~ w-, w- > l- vl~), (z > j j)
output BG_ttZ
launch BG_ttZ
```

# 10. ttW (fixed: skip intermediate W to avoid label conflict)
```
generate p p > t t~ w+, (t > b l+ vl), (t~ > b~ j j), (w+ > j j)
add process p p > t t~ w-, (t > b j j), (t~ > b~ l- vl~), (w- > j j)
output BG_ttW
launch BG_ttW
```

# 11. ttH
```
generate p p > t t~ h, (t > b w+, w+ > l+ vl), (t~ > b~ w-, w- > j j)
add process p p > t t~ h, (t > b w+, w+ > j j), (t~ > b~ w-, w- > l- vl~)
output BG_ttH
launch BG_ttH
```
