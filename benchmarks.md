# Speed Evaluation
| Scheme | Implementation | Key Generation [cycles] | Encapsulation [cycles] | Decapsulation [cycles] | 
| --- | --- | --- | --- | --- | 
| Kyber1024 | - | 1394148 | 1603776 | 1522900 | 
| Kyber1024 | OS | 1410591 | 1603988 | 1523175 | 
| Kyber1024 | SSC | 1381514 | 1603772 | 1595530 | 
| Kyber1024 | SSC/OS | 1397174 | 1603961 | 1595091 | 
| Kyber1024 | SSC/UR | 1378625 | 1600803 | 1588478 | 
| Kyber1024 | SSC/UR/OS | 1392837 | 1600366 | 1587419 | 
| Kyber1024 | UR | 1390307 | 1599858 | 1516783 | 
| Kyber1024 | UR/OS | 1405859 | 1600002 | 1517002 | 
| Kyber512 | - | 452919 | 586380 | 542576 | 
| Kyber512 | OS | 461693 | 586754 | 543332 | 
| Kyber512 | SSC | 446876 | 586403 | 579594 | 
| Kyber512 | SSC/OS | 454509 | 586621 | 579299 | 
| Kyber512 | SSC/UR | 445118 | 584425 | 575396 | 
| Kyber512 | SSC/UR/OS | 452423 | 584726 | 575183 | 
| Kyber512 | UR | 451149 | 584390 | 539350 | 
| Kyber512 | UR/OS | 458989 | 584242 | 539586 | 
| Kyber768 | - | 860227 | 1031603 | 967124 | 
| Kyber768 | OS | 872140 | 1030764 | 966848 | 
| Kyber768 | SSC | 850228 | 1030679 | 1021439 | 
| Kyber768 | SSC/OS | 862610 | 1030851 | 1021611 | 
| Kyber768 | SSC/UR | 847695 | 1027998 | 1015600 | 
| Kyber768 | SSC/UR/OS | 859547 | 1028254 | 1015863 | 
| Kyber768 | UR | 857238 | 1028466 | 962276 | 
| Kyber768 | UR/OS | 869024 | 1028112 | 962484 | 
| NewHope1024 | - | 1117398 | 1687272 | 1612960 | 
| NewHope1024 | OS | 1157331 | 1689375 | 1614804 | 
| NewHope1024 | UR | 1114557 | 1682415 | 1606700 | 
| NewHope1024 | UR/OS | 1153363 | 1684534 | 1608561 | 
| NewHope512 | - | 561161 | 865243 | 820130 | 
| NewHope512 | OS | 578850 | 865856 | 820742 | 
| NewHope512 | UR | 559339 | 862410 | 816595 | 
| NewHope512 | UR/OS | 576709 | 863278 | 817461 | 
| NewHope-Compact1024 | - | 658581 | 1022903 | 940023 | 
| NewHope-Compact1024 | OS | 686255 | 1025503 | 941076 | 
| NewHope-Compact1024 | SSC | 648206 | 1022773 | 1030809 | 
| NewHope-Compact1024 | SSC/OS | 675811 | 1024910 | 1033971 | 
| NewHope-Compact1024 | SSC/UR | 645528 | 1018235 | 1023308 | 
| NewHope-Compact1024 | SSC/UR/OS | 672061 | 1020354 | 1026452 | 
| NewHope-Compact1024 | UR | 655723 | 1018185 | 932715 | 
| NewHope-Compact1024 | UR/OS | 682271 | 1020713 | 933696 | 
| NewHope-Compact512 | - | 335991 | 531453 | 484416 | 
| NewHope-Compact512 | OS | 349692 | 532423 | 484945 | 
| NewHope-Compact512 | SSC | 330826 | 531282 | 526805 | 
| NewHope-Compact512 | SSC/OS | 344599 | 532323 | 528422 | 
| NewHope-Compact512 | SSC/UR | 329461 | 528972 | 522997 | 
| NewHope-Compact512 | SSC/UR/OS | 342670 | 529978 | 524579 | 
| NewHope-Compact512 | UR | 334536 | 529052 | 480530 | 
| NewHope-Compact512 | UR/OS | 347818 | 530131 | 481166 | 
| NewHope-Compact768 | - | 501885 | 782315 | 717250 | 
| NewHope-Compact768 | OS | 524181 | 784117 | 718950 | 
| NewHope-Compact768 | SSC | 494364 | 782471 | 786664 | 
| NewHope-Compact768 | SSC/OS | 516660 | 783986 | 788759 | 
| NewHope-Compact768 | SSC/UR | 491612 | 777413 | 778473 | 
| NewHope-Compact768 | SSC/UR/OS | 513198 | 779033 | 780674 | 
| NewHope-Compact768 | UR | 499259 | 777383 | 710642 | 
| NewHope-Compact768 | UR/OS | 520740 | 779185 | 712339 | 
# Memory Evaluation
| Scheme | Implementation | Key Generation [bytes] | Encapsulation [bytes] | Decapsulation [bytes] | 
| --- | --- | --- | --- | --- | 
| Kyber1024 | - | 4064 | 3384 | 3384 | 
| Kyber1024 | OS | 3776 | 3744 | 3760 | 
| Kyber1024 | SSC | 4064 | 3384 | 3384 | 
| Kyber1024 | SSC/OS | 3744 | 3384 | 3384 | 
| Kyber1024 | SSC/UR | 4064 | 3384 | 3384 | 
| Kyber1024 | SSC/UR/OS | 3744 | 3384 | 3384 | 
| Kyber1024 | UR | 4064 | 3384 | 3384 | 
| Kyber1024 | UR/OS | 3776 | 3744 | 3760 | 
| Kyber512 | - | 2896 | 2344 | 2360 | 
| Kyber512 | OS | 2392 | 2344 | 2360 | 
| Kyber512 | SSC | 2896 | 2344 | 2360 | 
| Kyber512 | SSC/OS | 2392 | 2344 | 2360 | 
| Kyber512 | SSC/UR | 2896 | 2344 | 2360 | 
| Kyber512 | SSC/UR/OS | 2392 | 2344 | 2360 | 
| Kyber512 | UR | 2896 | 2344 | 2360 | 
| Kyber512 | UR/OS | 2392 | 2344 | 2360 | 
| Kyber768 | - | 3552 | 2856 | 2864 | 
| Kyber768 | OS | 3240 | 2856 | 2864 | 
| Kyber768 | SSC | 3544 | 2848 | 2856 | 
| Kyber768 | SSC/OS | 3232 | 2848 | 2856 | 
| Kyber768 | SSC/UR | 3544 | 2848 | 2856 | 
| Kyber768 | SSC/UR/OS | 3232 | 2848 | 2856 | 
| Kyber768 | UR | 3552 | 2856 | 2864 | 
| Kyber768 | UR/OS | 3240 | 2856 | 2864 | 
| NewHope1024 | - | 4920 | 4904 | 4920 | 
| NewHope1024 | OS | 3072 | 4904 | 4920 | 
| NewHope1024 | UR | 4920 | 4904 | 4920 | 
| NewHope1024 | UR/OS | 3072 | 4904 | 4920 | 
| NewHope512 | - | 2880 | 2864 | 2880 | 
| NewHope512 | OS | 2056 | 2864 | 2880 | 
| NewHope512 | UR | 2880 | 2864 | 2880 | 
| NewHope512 | UR/OS | 2056 | 2864 | 2880 | 
| NewHope-Compact1024 | - | 5024 | 5024 | 5024 | 
| NewHope-Compact1024 | OS | 3176 | 5024 | 5024 | 
| NewHope-Compact1024 | SSC | 5032 | 5024 | 5024 | 
| NewHope-Compact1024 | SSC/OS | 3183 | 5023 | 5023 | 
| NewHope-Compact1024 | SSC/UR | 5032 | 5024 | 5024 | 
| NewHope-Compact1024 | SSC/UR/OS | 3184 | 5024 | 5024 | 
| NewHope-Compact1024 | UR | 5024 | 5024 | 5024 | 
| NewHope-Compact1024 | UR/OS | 3176 | 5024 | 5024 | 
| NewHope-Compact512 | - | 2984 | 2984 | 2984 | 
| NewHope-Compact512 | OS | 2160 | 2984 | 2984 | 
| NewHope-Compact512 | SSC | 2976 | 2984 | 2984 | 
| NewHope-Compact512 | SSC/OS | 2152 | 2984 | 2984 | 
| NewHope-Compact512 | SSC/UR | 2976 | 2984 | 2984 | 
| NewHope-Compact512 | SSC/UR/OS | 2152 | 2984 | 2984 | 
| NewHope-Compact512 | UR | 2984 | 2984 | 2984 | 
| NewHope-Compact512 | UR/OS | 2160 | 2984 | 2984 | 
| NewHope-Compact768 | - | 3936 | 3936 | 3936 | 
| NewHope-Compact768 | OS | 2600 | 3936 | 3936 | 
| NewHope-Compact768 | SSC | 3952 | 3944 | 3944 | 
| NewHope-Compact768 | SSC/OS | 2616 | 3944 | 3944 | 
| NewHope-Compact768 | SSC/UR | 3952 | 3944 | 3944 | 
| NewHope-Compact768 | UR | 3936 | 3936 | 3936 | 
# Size Evaluation
| Scheme | Implementation | .text [bytes] | .data [bytes] | .bss [bytes] | Total [bytes] | 
| --- | --- | --- | --- | --- | --- | 
| Kyber1024 | - | 5056 | 0 | 0 | 5056 | 
| Kyber1024 | OS | 5056 | 0 | 0 | 5056 | 
| Kyber1024 | SSC | 5056 | 0 | 0 | 5056 | 
| Kyber1024 | SSC/OS | 5056 | 0 | 0 | 5056 | 
| Kyber1024 | SSC/UR | 65844 | 0 | 0 | 65844 | 
| Kyber1024 | SSC/UR/OS | 65844 | 0 | 0 | 65844 | 
| Kyber1024 | UR | 65844 | 0 | 0 | 65844 | 
| Kyber1024 | UR/OS | 65844 | 0 | 0 | 65844 | 
| Kyber512 | - | 5056 | 0 | 0 | 5056 | 
| Kyber512 | OS | 5056 | 0 | 0 | 5056 | 
| Kyber512 | SSC | 5056 | 0 | 0 | 5056 | 
| Kyber512 | SSC/OS | 5056 | 0 | 0 | 5056 | 
| Kyber512 | SSC/UR | 65844 | 0 | 0 | 65844 | 
| Kyber512 | SSC/UR/OS | 65844 | 0 | 0 | 65844 | 
| Kyber512 | UR | 65844 | 0 | 0 | 65844 | 
| Kyber512 | UR/OS | 65844 | 0 | 0 | 65844 | 
| Kyber768 | - | 5056 | 0 | 0 | 5056 | 
| Kyber768 | OS | 5056 | 0 | 0 | 5056 | 
| Kyber768 | SSC | 5056 | 0 | 0 | 5056 | 
| Kyber768 | SSC/OS | 5056 | 0 | 0 | 5056 | 
| Kyber768 | SSC/UR | 65844 | 0 | 0 | 65844 | 
| Kyber768 | SSC/UR/OS | 65844 | 0 | 0 | 65844 | 
| Kyber768 | UR | 65844 | 0 | 0 | 65844 | 
| Kyber768 | UR/OS | 65844 | 0 | 0 | 65844 | 
| NewHope1024 | - | 8144 | 0 | 0 | 8144 | 
| NewHope1024 | OS | 8208 | 0 | 0 | 8208 | 
| NewHope1024 | UR | 468208 | 0 | 0 | 468208 | 
| NewHope1024 | UR/OS | 472304 | 0 | 0 | 472304 | 
| NewHope512 | - | 7404 | 0 | 0 | 7404 | 
| NewHope512 | OS | 7468 | 0 | 0 | 7468 | 
| NewHope512 | UR | 213980 | 0 | 0 | 213980 | 
| NewHope512 | UR/OS | 216028 | 0 | 0 | 216028 | 
| NewHope-Compact1024 | - | 10308 | 0 | 0 | 10308 | 
| NewHope-Compact1024 | OS | 10360 | 0 | 0 | 10360 | 
| NewHope-Compact1024 | SSC | 10356 | 0 | 0 | 10356 | 
| NewHope-Compact1024 | SSC/OS | 10408 | 0 | 0 | 10408 | 
| NewHope-Compact1024 | SSC/UR | 134008 | 0 | 0 | 134008 | 
| NewHope-Compact1024 | SSC/UR/OS | 134508 | 0 | 0 | 134508 | 
| NewHope-Compact1024 | UR | 133960 | 0 | 0 | 133960 | 
| NewHope-Compact1024 | UR/OS | 134460 | 0 | 0 | 134460 | 
| NewHope-Compact512 | - | 9256 | 0 | 0 | 9256 | 
| NewHope-Compact512 | OS | 9312 | 0 | 0 | 9312 | 
| NewHope-Compact512 | SSC | 9304 | 0 | 0 | 9304 | 
| NewHope-Compact512 | SSC/OS | 9356 | 0 | 0 | 9356 | 
| NewHope-Compact512 | SSC/UR | 74648 | 0 | 0 | 74648 | 
| NewHope-Compact512 | SSC/UR/OS | 75148 | 0 | 0 | 75148 | 
| NewHope-Compact512 | UR | 74600 | 0 | 0 | 74600 | 
| NewHope-Compact512 | UR/OS | 75104 | 0 | 0 | 75104 | 
| NewHope-Compact768 | - | 9784 | 0 | 0 | 9784 | 
| NewHope-Compact768 | OS | 9840 | 0 | 0 | 9840 | 
| NewHope-Compact768 | SSC | 9832 | 0 | 0 | 9832 | 
| NewHope-Compact768 | SSC/OS | 9884 | 0 | 0 | 9884 | 
| NewHope-Compact768 | SSC/UR | 101724 | 0 | 0 | 101724 | 
| NewHope-Compact768 | SSC/UR/OS | 102224 | 0 | 0 | 102224 | 
| NewHope-Compact768 | UR | 101676 | 0 | 0 | 101676 | 
| NewHope-Compact768 | UR/OS | 102180 | 0 | 0 | 102180 | 
## Abbreviations
`UR`: USE_REPT
`OS`: OPTIMIZE_STACK
`SSC`: SMALL_SECRET_KEY
Default option: `OS`
